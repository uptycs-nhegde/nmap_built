top_srcdir = ..
srcdir = .

CXX = g++
CXXFLAGS = -g -O2 -Wall -fno-strict-aliasing
CPPFLAGS = -I$(top_srcdir)/liblinear -I$(top_srcdir)/liblua -I$(top_srcdir)/libdnet-stripped/include -I$(top_srcdir)/libz -I$(top_srcdir)/libpcre/src  -I$(top_srcdir)/libpcap -I$(top_srcdir)/nbase -I$(top_srcdir)/nsock/include $(DEFS)
DEFS = -DHAVE_CONFIG_H
DEFS += -D_FORTIFY_SOURCE=2
AR = ar
RANLIB = ranlib

LIBDNETDIR = libdnet-stripped
LIBPCAPDIR = libpcap

TARGET = libnetutil.a

SRCS = $(srcdir)/netutil.cc $(srcdir)/PacketElement.cc $(srcdir)/NetworkLayerElement.cc $(srcdir)/ARPHeader.cc $(srcdir)/PacketElement.cc $(srcdir)/NetworkLayerElement.cc $(srcdir)/TransportLayerElement.cc $(srcdir)/ARPHeader.cc $(srcdir)/EthernetHeader.cc $(srcdir)/ICMPv4Header.cc $(srcdir)/ICMPv6Header.cc $(srcdir)/IPv4Header.cc $(srcdir)/IPv6Header.cc $(srcdir)/TCPHeader.cc $(srcdir)/UDPHeader.cc $(srcdir)/RawData.cc $(srcdir)/HopByHopHeader.cc $(srcdir)/DestOptsHeader.cc $(srcdir)/FragmentHeader.cc $(srcdir)/RoutingHeader.cc $(srcdir)/PacketParser.cc
OBJS = netutil.o PacketElement.o NetworkLayerElement.o TransportLayerElement.o ARPHeader.o EthernetHeader.o ICMPv4Header.o ICMPv6Header.o IPv4Header.o IPv6Header.o TCPHeader.o UDPHeader.o RawData.o HopByHopHeader.o DestOptsHeader.o FragmentHeader.o RoutingHeader.o  PacketParser.o

all: $(TARGET)

$(TARGET): $(OBJS)
	rm -f $@
	$(AR) cr $@ $(OBJS)
	$(RANLIB) $@

clean:
	rm -f $(OBJS) $(TARGET)

distclean: clean
	rm -rf Makefile makefile.dep

Makefile: Makefile.in
	cd $(top_srcdir) && ./config.status

.cc.o:
	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS) $< -o $@

makefile.dep:
	$(CXX) -MM $(CPPFLAGS) $(SRCS) > $@
-include makefile.dep
