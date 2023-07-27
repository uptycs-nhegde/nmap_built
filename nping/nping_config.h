/* nping_config.h.  Generated from nping_config.h.in by configure.  */
/* nping_config.h.in.  Generated from configure.ac by autoheader.  */

/* Define if building universal (internal helper macro) */
/* #undef AC_APPLE_UNIVERSAL_BUILD */

/* BSD/OS */
/* #undef BSDI */

/* DEC Alpha */
/* #undef DEC */

/* FreeBSD */
/* #undef FREEBSD */

/* Define to 1 if you have the <inttypes.h> header file. */
#define HAVE_INTTYPES_H 1

/* struct ip has ip_sum member */
#define HAVE_IP_IP_SUM 1

/* Define to 1 if you have the `cfg' library (-lcfg). */
/* #undef HAVE_LIBCFG */

/* Define to 1 if you have the `crypt' library (-lcrypt). */
/* #undef HAVE_LIBCRYPT */

/* Define to 1 if you have the `m' library (-lm). */
/* #undef HAVE_LIBM */

/* Define to 1 if you have the `nm' library (-lnm). */
/* #undef HAVE_LIBNM */

/* Define to 1 if you have the `odm' library (-lodm). */
/* #undef HAVE_LIBODM */

/* Have libpcap library */
/* #undef HAVE_LIBPCAP */

/* Define to 1 if you have the <memory.h> header file. */
#define HAVE_MEMORY_H 1

/* Define to 1 if you have the <net/bpf.h> header file. */
/* #undef HAVE_NET_BPF_H */

/* Have OpenSSL library */
/* #undef HAVE_OPENSSL */

/* Define to 1 if you have the <pwd.h> header file. */
#define HAVE_PWD_H 1

/* ssignal function is accessible */
#define HAVE_SIGNAL 1

/* struct sockaddr_in6 has sin6_len member */
/* #undef HAVE_SOCKADDR_IN6_SIN6_LEN */

/* struct sockaddr_in has sin_len member */
/* #undef HAVE_SOCKADDR_IN_SIN_LEN */

/* struct sockaddr has sa_len member */
/* #undef HAVE_SOCKADDR_SA_LEN */

/* Define to 1 if you have the <stdint.h> header file. */
#define HAVE_STDINT_H 1

/* Define to 1 if you have the <stdlib.h> header file. */
#define HAVE_STDLIB_H 1

/* Define to 1 if you have the `strerror' function. */
#define HAVE_STRERROR 1

/* Define to 1 if you have the <strings.h> header file. */
#define HAVE_STRINGS_H 1

/* Define to 1 if you have the <string.h> header file. */
#define HAVE_STRING_H 1

/* Define to 1 if you have the <sys/ioccom.h> header file. */
/* #undef HAVE_SYS_IOCCOM_H */

/* Define to 1 if you have the <sys/sockio.h> header file. */
/* #undef HAVE_SYS_SOCKIO_H */

/* Define to 1 if you have the <sys/stat.h> header file. */
#define HAVE_SYS_STAT_H 1

/* Define to 1 if you have the <sys/time.h> header file. */
/* #undef HAVE_SYS_TIME_H */

/* Define to 1 if you have the <sys/types.h> header file. */
#define HAVE_SYS_TYPES_H 1

/* Define to 1 if you have the <termios.h> header file. */
#define HAVE_TERMIOS_H 1

/* Define to 1 if you have the <unistd.h> header file. */
#define HAVE_UNISTD_H 1

/* HP-UX */
/* #undef HPUX */

/* */
/* #undef IN_ADDR_DEEPSTRUCT */

/* IRIX */
/* #undef IRIX */

/* Linux */
#define LINUX 1

/* Apple OS X */
/* #undef MACOSX */

/* NetBSD */
/* #undef NETBSD */

/* OpenBSD */
/* #undef OPENBSD */

/* Define to the address where bug reports for this package should be sent. */
#define PACKAGE_BUGREPORT ""

/* Define to the full name of this package. */
#define PACKAGE_NAME ""

/* Define to the full name and version of this package. */
#define PACKAGE_STRING ""

/* Define to the one symbol short name of this package. */
#define PACKAGE_TARNAME ""

/* Define to the home page for this package. */
#define PACKAGE_URL ""

/* Define to the version of this package. */
#define PACKAGE_VERSION ""

/* Sun/Oracle Solaris */
/* #undef SOLARIS */

/* sprintf(9f) returns its first argument, not the number of characters
   printed */
/* #undef SPRINTF_RETURNS_STRING */

/* Define to 1 if you have the ANSI C header files. */
#define STDC_HEADERS 1

/* */
/* #undef STUPID_SOLARIS_CHECKSUM_BUG */

/* SunOS 4 */
/* #undef SUNOS */

/* Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
   significant byte first (like Motorola and SPARC, unlike Intel). */
#if defined AC_APPLE_UNIVERSAL_BUILD
# if defined __BIG_ENDIAN__
#  define WORDS_BIGENDIAN 1
# endif
#else
# ifndef WORDS_BIGENDIAN
/* #  undef WORDS_BIGENDIAN */
# endif
#endif

/* C99-specified function identifier */
/* #undef __func__ */

/* Define to `__inline__' or `__inline' if that's what the C compiler
   calls it, or to nothing if 'inline' is not supported under any name.  */
#ifndef __cplusplus
/* #undef inline */
#endif
