#
# nsock regression test suite
# Same license as nmap -- see https://nmap.org/book/man-legal.html
##

NBASEDIR=/nmap/nmap/nbase
NSOCKLIB=../src/libnsock.a
NBASELIB=$(NBASEDIR)/libnbase.a

CC 	= gcc
CPPFLAGS = -I/nmap/nmap/libpcap  -I/nmap/nmap/nbase -I../include
CFLAGS	= -g -O2 -Wall 
LDFLAGS	= -L/nmap/nmap/libpcap  -L/nmap/nmap/nbase
LIBS	=  /nmap/nmap/libpcap/libpcap.a -ldl 

SRC = tests_main.c \
      basic.c \
      timer.c \
      logs.c \
      connect.c \
      ghlists.c \
      ghheaps.c \
      proxychain.c \
      cancel.c

OBJ = $(SRC:.c=.o)

EXE = tests_main

all: $(SRC) $(EXE)

$(EXE): $(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) -o $@ $(NSOCKLIB) $(NBASELIB) $(LIBS)

.c.o:
	$(CC) -c $(CPPFLAGS) $(CFLAGS) $< -o $@

clean:
	$(RM) $(OBJ) $(EXE)

rebuild: clean $(EXE)

.PHONY: clean rebuild
