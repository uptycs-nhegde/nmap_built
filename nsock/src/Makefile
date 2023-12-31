NSOCK_VERSION = 0.02
prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
sbindir = ${exec_prefix}/sbin
mandir = ${datarootdir}/man
srcdir = .
datarootdir = ${prefix}/share

CC = gcc
AR = ar
RANLIB = ranlib
CCOPT =
DEFS = -DHAVE_CONFIG_H -DNSOCK_VERSION=\"$(NSOCK_VERSION)\"
# With GCC, add extra security checks to source code.
DEFS += -D_FORTIFY_SOURCE=2
INCLS = -I../include
CFLAGS = -g -O2 -Wall  $(CCOPT)
# CFLAGS = -g -Wall $(DEFS) $(INCLS)
CPPFLAGS = -I/nmap/nmap/libpcap  -I/nmap/nmap/nbase $(DEFS) $(INCLS)
STATIC =
SHTOOL = ./shtool
INSTALL = $(SHTOOL) install
MAKEDEPEND = @MAKEDEPEND@
RPMTDIR=$(HOME)/rpmdir
NBASEDIR=/nmap/nmap/nbase
NSOCKTESTDIR=../tests

TARGET = libnsock.a

SRCS = 	error.c filespace.c gh_heap.c nsock_connect.c nsock_core.c \
	nsock_iod.c nsock_read.c nsock_timers.c nsock_write.c \
	nsock_ssl.c nsock_event.c nsock_pool.c netutils.c nsock_pcap.c \
	nsock_engines.c engine_select.c engine_epoll.c engine_kqueue.c \
	engine_poll.c nsock_proxy.c nsock_log.c proxy_http.c proxy_socks4.c

OBJS =	error.o filespace.o gh_heap.o nsock_connect.o nsock_core.o \
	nsock_iod.o nsock_read.o nsock_timers.o nsock_write.o \
	nsock_ssl.o nsock_event.o nsock_pool.o netutils.o nsock_pcap.o \
	nsock_engines.o engine_select.o engine_epoll.o engine_kqueue.o \
	engine_poll.o nsock_proxy.o nsock_log.o proxy_http.o proxy_socks4.o

DEPS =	error.h filespace.h gh_list.h nsock_internal.h netutils.h nsock_pcap.h \
	nsock_log.h nsock_proxy.h gh_heap.h ../include/nsock.h \
	$(NBASEDIR)/libnbase.a

.c.o:
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

all: $(TARGET)

$(TARGET): $(DEPS) $(OBJS)
	rm -f $@
	$(AR) cr $@ $(OBJS)
	$(RANLIB) $@

$(NBASEDIR)/libnbase.a: $(NBASEDIR)/Makefile
	cd $(NBASEDIR) && $(MAKE)

clean-test:
	cd $(NSOCKTESTDIR) && $(MAKE) clean

clean: clean-test
	rm -f $(OBJS) $(TARGET)

distclean: clean
	rm -f Makefile makefile.dep config.log config.status ../include/nsock_config.h $(NSOCKTESTDIR)/Makefile

depend:
	$(MAKEDEPEND) $(INCLS) -s "# DO NOT DELETE" -- $(DEFS) -- $(SRCS)

check:
	cd $(NSOCKTESTDIR) && $(MAKE) && ./run_tests.sh

${srcdir}/configure: configure.ac
	cd ${srcdir} && autoconf

# autoheader might not change config.h.in, so touch a stamp file.
${srcdir}/config.h.in: stamp-h.in
${srcdir}/stamp-h.in: configure.ac acconfig.h \
	config.h.top config.h.bot
	cd ${srcdir} && autoheader
	echo timestamp > ${srcdir}/stamp-h.in

config.h: stamp-h
stamp-h: config.h.in config.status
	./config.status

Makefile: Makefile.in config.status
	./config.status

config.status: configure
	./config.status --recheck

makefile.dep:
	$(CC) -MM $(CPPFLAGS) $(SRCS) > $@
-include makefile.dep
