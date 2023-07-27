---
-- Creates and parses NetBIOS traffic. The primary use for this is to send
-- NetBIOS name requests.
--
-- @author Ron Bowes <ron@skullsecurity.net>
-- @copyright Same as Nmap--See https://nmap.org/book/man-legal.html

local dns = require "dns"
local math = require "math"
local nmap = require "nmap"
local stdnse = require "stdnse"
local string = require "string"
local table = require "table"
_ENV = stdnse.module("netbios", stdnse.seeall)


types = {
  NB = 32,
  NBSTAT = 33,
}

--- Encode a NetBIOS name for transport.
--
-- Most packets that use the NetBIOS name require this encoding to happen
-- first. It takes a name containing any possible character, and converted it
-- to all uppercase characters (so it can, for example, pass case-sensitive
-- data in a case-insensitive way)
--
-- There are two levels of encoding performed:
-- * L1: Pad the string to 16 characters withs spaces (or NULLs if it's the
--     wildcard "*") and replace each byte with two bytes representing each
--     of its nibbles, plus 0x41.
-- * L2: Prepend the length to the string, and to each substring in the scope
--     (separated by periods).
--@param name The name that will be encoded (eg. "TEST1").
--@param scope [optional] The scope to encode it with. I've never seen scopes used
--       in the real world (eg, "insecure.org").
--@return The L2-encoded name and scope
--        (eg. "\x20FEEFFDFEDBCACACACACACACACACAAA\x08insecure\x03org")
function name_encode(name, scope)

  stdnse.debug3("Encoding name '%s'", name)
  -- Truncate or pad the string to 16 bytes
  if(#name >= 16) then
    name = string.sub(name, 1, 16)
  else
    local padding = " "
    if name == "*" then
      padding = "\0"
    end

    name = name .. string.rep(padding, 16 - #name)
  end

  -- Convert to uppercase
  name = string.upper(name)

  -- Do the L1 encoding
  local L1_encoded = {}
  for i=1, #name, 1 do
    local b = string.byte(name, i)
    L1_encoded[i*2-1] = string.char(((b & 0xF0) >> 4) + 0x41)
    L1_encoded[i*2]   = string.char((b & 0x0F) + 0x41)
  end

  -- Do the L2 encoding
  local L2_encoded = { string.char(32), table.concat(L1_encoded) }

  if scope ~= nil then
    -- Split the scope at its periods
    local piece
    for piece in string.gmatch(scope, "[^.]+") do
      L2_encoded[#L2_encoded+1] = string.char(#piece) .. piece
    end
  end

  L2_encoded = table.concat(L2_encoded)
  stdnse.debug3("=> '%s'", L2_encoded)
  return L2_encoded
end



--- Converts an encoded name to the string representation.
--
-- If the encoding is invalid, it will still attempt to decode the string as
-- best as possible.
--@param encoded_name The L2-encoded name
--@return the decoded name and the scope. The name will still be padded, and the
--         scope will never be nil (empty string is returned if no scope is present)
function name_decode(encoded_name)
  local name = ""
  local scope = ""

  local len = string.byte(encoded_name, 1)
  local i

  stdnse.debug3("Decoding name '%s'", encoded_name)

  name = name:gsub("(.)(.)", function (a, b)
      local ch = ((string.byte(a) - 0x41) << 4) | (string.byte(b) - 0x41)
      return string.char(ch)
    end)

  -- Decode the scope
  local pos = 34
  while #encoded_name > pos do
    local len = string.byte(encoded_name, pos)
    scope = scope .. string.sub(encoded_name, pos + 1, pos + len) .. "."
    pos = pos + 1 + len
  end

  -- If there was a scope, remove the trailing period
  if(#scope > 0) then
    scope = string.sub(scope, 1, #scope - 1)
  end

  stdnse.debug3("=> '%s'", name)

  return name, scope
end

--- Sends out a UDP probe on port 137 to get a human-readable list of names the
--  the system is using.
--@param host The IP or hostname to check.
--@param prefix [optional] The prefix to put on each line when it's returned.
--@return (status, result) If status is true, the result is a human-readable
--        list of names. Otherwise, result is an error message.
function get_names(host, prefix)

  local status, names, statistics = do_nbstat(host)

  if(prefix == nil) then
    prefix = ""
  end


  if(status) then
    local result = ""
    for i = 1, #names, 1 do
      result = result .. string.format("%s%s<%02x>\n", prefix, names[i]['name'], names[i]['prefix'])
    end

    return true, result
  else
    return false, names
  end
end

--- Sends out a UDP probe on port 137 to get the server's name (that is, the
--  entry in its NBSTAT table with a 0x20 suffix).
--@param host The IP or hostname of the server.
--@param names [optional] The names to use, from <code>do_nbstat</code>.
--@return (status, result) If status is true, the result is the NetBIOS name.
--        otherwise, result is an error message.
function get_server_name(host, names)

  local status
  local i

  if names == nil then
    status, names = do_nbstat(host)

    if(status == false) then
      return false, names
    end
  end

  for i = 1, #names, 1 do
    if names[i]['suffix'] == 0x20 then
      return true, names[i]['name']
    end
  end

  return true, nil
end

--- Sends out a UDP probe on port 137 to get the workstation's name (that is, the
--  unique entry in its NBSTAT table with a 0x00 suffix).
--@param host The IP or hostname of the server.
--@param names [optional] The names to use, from <code>do_nbstat</code>.
--@return (status, result) If status is true, the result is the NetBIOS name.
--        otherwise, result is an error message.
function get_workstation_name(host, names)

  local status
  local i

  if names == nil then
    status, names = do_nbstat(host)

    if(status == false) then
      return false, names
    end
  end

  for i = 1, #names, 1 do
    if names[i]['suffix'] == 0x00 and (names[i]['flags'] & 0x8000) == 0 then
      return true, names[i]['name']
    end
  end

  return true, nil
end
--- Sends out a UDP probe on port 137 to get the user's name
--
-- User name is the entry in its NBSTAT table with a 0x03 suffix, that isn't
-- the same as the server's name. If the username can't be determined, which is
-- frequently the case, nil is returned.
--@param host The IP or hostname of the server.
--@param names [optional] The names to use, from <code>do_nbstat</code>.
--@return (status, result) If status is true, the result is the NetBIOS name or nil.
--        otherwise, result is an error message.
function get_user_name(host, names)

  local status, server_name = get_server_name(host, names)

  if(status == false) then
    return false, server_name
  end

  if(names == nil) then
    status, names = do_nbstat(host)

    if(status == false) then
      return false, names
    end
  end

  for i = 1, #names, 1 do
    if names[i]['suffix'] == 0x03 and names[i]['name'] ~= server_name then
      return true, names[i]['name']
    end
  end

  return true, nil

end


--- This is the function that actually handles the UDP query to retrieve
-- the NBSTAT information.
--
-- We make use of the Nmap registry here, so if another script has already
-- performed a nbstat query, the result can be re-used.
--
-- The NetBIOS request's header looks like this:
--<code>
--  --------------------------------------------------
--  |  15 14 13 12 11 10 9  8  7  6  5  4  3  2  1  0 |
--  |                  NAME_TRN_ID                    |
--  | R |   OPCODE  |      NM_FLAGS      |   RCODE    | (FLAGS)
--  |                    QDCOUNT                      |
--  |                    ANCOUNT                      |
--  |                    NSCOUNT                      |
--  |                    ARCOUNT                      |
--  --------------------------------------------------
--</code>
--
-- In this case, the TRN_ID is a constant (0x1337, what else?), the flags
-- are 0, and we have one question. All fields are network byte order.
--
-- The body of the packet is a list of names to check for in the following
-- format:
-- * (ntstring) encoded name
-- * (2 bytes)  query type (0x0021 = NBSTAT)
-- * (2 bytes)  query class (0x0001 = IN)
--
-- The response header is the exact same, except it'll have some flags set
-- (0x8000 for sure, since it's a response), and ANCOUNT will be 1. The format
-- of the answer is:
--
-- * (ntstring) requested name
-- * (2 bytes)  query type
-- * (2 bytes)  query class
-- * (2 bytes)  time to live
-- * (2 bytes)  record length
-- * (1 byte)   number of names
-- * [for each name]
-- *  (16 bytes) padded name, with a 1-byte suffix
-- *  (2 bytes)  flags
-- * (variable) statistics (usually mac address)
--
--@param host The IP or hostname of the system.
--@return (status, names, statistics) If status is true, then the servers names are
--        returned as a table containing 'name', 'suffix', and 'flags'.
--        Otherwise, names is an error message and statistics is undefined.
function do_nbstat(host)

  local status, err
  local socket = nmap.new_socket()
  local encoded_name = name_encode("*")
  local statistics
  local reg
  if type(host) == "string" then --ip
    stdnse.debug3("Performing nbstat on host '%s'", host)
    nmap.registry.netbios = nmap.registry.netbios or {}
    nmap.registry.netbios[host] = nmap.registry.netbios[host] or {}
    reg = nmap.registry.netbios[host]
  else
    stdnse.debug3("Performing nbstat on host '%s'", host.ip)
    if host.registry.netbios == nil and
      nmap.registry.netbios ~= nil and
      nmap.registry.netbios[host.ip] ~= nil then
      host.registry.netbios = nmap.registry.netbios[host.ip]
    end
    host.registry.netbios = host.registry.netbios or {}
    reg = host.registry.netbios
  end

  -- Check if it's cached in the registry for this host
  if(reg["nbstat_names"] ~= nil) then
    stdnse.debug3(" |_ [using cached value]")
    return true, reg["nbstat_names"], reg["nbstat_statistics"]
  end

  -- Create the query header
  local query = string.pack(">I2I2I2I2I2I2",
  0x1337,  -- Transaction id
  0x0000,  -- Flags
  1,       -- Questions
  0,       -- Answers
  0,       -- Authority
  0        -- Extra
  ) .. string.pack(">zI2I2",
  encoded_name, -- Encoded name
  0x0021,       -- Query type (0x21 = NBSTAT)
  0x0001        -- Class = IN
  )
  status, err = socket:connect(host, 137, "udp")
  if(status == false) then
    return false, err
  end

  status, err = socket:send(query)
  if(status == false) then
    return false, err
  end

  socket:set_timeout(1000)

  local status, result = socket:receive_bytes(1)
  if(status == false) then
    return false, result
  end

  local close_status, err = socket:close()
  if(close_status == false) then
    return false, err
  end

  if(status) then
    local pos, TRN_ID, FLAGS, QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT, rr_name, rr_type, rr_class, rr_ttl
    local rrlength, name_count

    TRN_ID, FLAGS, QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT, pos = string.unpack(">I2I2I2I2I2I2", result)

    -- Sanity check the result (has to have the same TRN_ID, 1 answer, and proper flags)
    if(TRN_ID ~= 0x1337) then
      return false, string.format("Invalid transaction ID returned: 0x%04x", TRN_ID)
    end
    if(ANCOUNT ~= 1) then
      return false, "Server returned an invalid number of answers"
    end
    if FLAGS & 0x8000 == 0 then
      return false, "Server's flags didn't indicate a response"
    end
    if FLAGS & 0x0007 ~= 0 then
      return false, string.format("Server returned a NetBIOS error: 0x%02x", FLAGS & 0x0007)
    end

    -- Start parsing the answer field
    rr_name, rr_type, rr_class, rr_ttl, pos = string.unpack(">zI2I2I4", result, pos)

    -- More sanity checks
    if(rr_name ~= encoded_name) then
      return false, "Server returned incorrect name"
    end
    if(rr_class ~= 0x0001) then
      return false, "Server returned incorrect class"
    end
    if(rr_type ~= 0x0021) then
      return false, "Server returned incorrect query type"
    end

    rrlength, name_count, pos = string.unpack(">I2B", result, pos)

    local names = {}
    for i = 1, name_count do
      local name, suffix, flags

      -- Instead of reading the 16-byte name and pulling off the suffix,
      -- we read the first 15 bytes and then the 1-byte suffix.
      name, suffix, flags, pos = string.unpack(">c15BI2", result, pos)
      name = string.gsub(name, "[ ]*$", "")

      names[i] = {}
      names[i]['name']   = name
      names[i]['suffix'] = suffix
      names[i]['flags']  = flags

      -- Decrement the length
      rrlength = rrlength - 18
    end

    if(rrlength > 0) then
      rrlength = rrlength - 1
    end
    statistics, pos = string.unpack(string.format(">c%d", rrlength), result, pos)

    -- Put it in the registry, in case anybody else needs it
    reg["nbstat_names"] = names
    reg["nbstat_statistics"] = statistics

    return true, names, statistics

  else
    return false, "Name query failed: " .. result
  end
end

function nbquery(host, nbname, options)
  -- override any options or set the default values
  local options = options or {}
  options.port = options.port or 137
  options.retPkt = options.retPkt or true
  options.dtype = options.dtype or types.NB
  options.host = host.ip
  options.flags = options.flags or ( options.multiple and 0x0110 )
  options.id = math.random(0xFFFF)

  -- encode and chop off the leading byte, as the dns library takes care of
  -- specifying the length
  local encoded_name = name_encode(nbname):sub(2)

  local status, response = dns.query( encoded_name, options )
  if ( not(status) ) then return false, "ERROR: nbquery failed" end

  local results = {}
  -- discard any additional responses
  if ( options.multiple and #response > 0 ) then
    for _, resp in ipairs(response) do
      assert( options.id == resp.output.id, "Received packet with invalid transaction ID" )
      if ( not(resp.output.answers) or #resp.output.answers < 1 ) then
        return false, "ERROR: Response contained no answers"
      end
      local dname = string.char(#resp.output.answers[1].dname) .. resp.output.answers[1].dname
      table.insert( results, { peer = resp.peer, name = name_decode(dname), data = resp.output.answers[1].data } )
    end
    return true, results
  else
    local dname = string.char(#response.answers[1].dname) .. response.answers[1].dname
    return true, { { peer = host.ip, name = name_decode(dname), data = response.answers[1].data } }
  end
end

---Convert the 16-bit flags field to a string.
--@param flags The 16-bit flags field
--@return A string representing the flags
function flags_to_string(flags)
  local result = {}

  if flags & 0x8000 ~= 0 then
    result[#result+1] = "<group>"
  else
    result[#result+1] = "<unique>"
  end

  if flags & 0x1000 ~= 0 then
    result[#result+1] = "<deregister>"
  end

  if flags & 0x0800 ~= 0 then
    result[#result+1] = "<conflict>"
  end

  if flags & 0x0400 ~= 0 then
    result[#result+1] = "<active>"
  end

  if flags & 0x0200 ~= 0 then
    result[#result+1] = "<permanent>"
  end

  return table.concat(result)
end


return _ENV;
