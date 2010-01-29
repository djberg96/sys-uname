/******************************************************************************
 * uname.c - Ruby extension for returning uname information on Unix platforms.
 *
 * Author: Daniel Berger
 *****************************************************************************/
#include <ruby.h>
#include <sys/utsname.h>

#define SYS_UNAME_VERSION "0.8.4"

/* Solaris */
#ifdef HAVE_SYS_SYSTEMINFO_H
#define BUFSIZE 257           /* Set as per the sysinfo(2) manpage */
#include <sys/systeminfo.h>
#endif

/* BSD platforms, including OS X */
#ifdef HAVE_SYSCTL
#include <sys/sysctl.h>
static int get_model(char *buf, int n)
{
   size_t sz = n;
   int mib[2];

   mib[0] = CTL_HW;
   mib[1] = HW_MODEL;
   return sysctl(mib, 2, buf, &sz, NULL, 0);
}
#endif

#ifdef __cplusplus
extern "C" 
{
#endif

VALUE sUname;

/*
 * Returns a struct of type UnameStruct that contains sysname, nodename,
 * machine, version, and release.  On Solaris, it will also include 
 * architecture and platform.  On HP-UX, it will also include id_number.
 */
static VALUE uname_uname_all()
{
   struct utsname u;
   uname(&u);

/* Extra brackets are for C89 compliance */
{
#ifdef HAVE_SYS_SYSTEMINFO_H
   char platform[BUFSIZE];
   char arch[BUFSIZE];
   sysinfo(SI_ARCHITECTURE, arch, BUFSIZE);
   sysinfo(SI_PLATFORM, platform, BUFSIZE);
#endif

#ifdef HAVE_SYSCTL
   char model[BUFSIZ];
   get_model(model, sizeof(model));
#endif

   return rb_struct_new(sUname,
      rb_str_new2(u.sysname),
      rb_str_new2(u.nodename),
      rb_str_new2(u.machine),
      rb_str_new2(u.version),
      rb_str_new2(u.release)
#ifdef HAVE_SYS_SYSTEMINFO_H
      ,rb_str_new2(arch),
      rb_str_new2(platform)
#endif

#ifdef HAVE_SYSCTL
      ,rb_str_new2(model)
#endif

#if defined(__hpux)
      ,rb_str_new2(u.__idnumber)
#endif
   );
}
}

/*
 * Returns the nodename.  This is usually, but not necessarily, the 
 * same as the system's hostname.
 */
static VALUE uname_nodename()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.nodename);
}

/*
 * Returns the machine hardware type, e.g. "i686".
 */
static VALUE uname_machine()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.machine);
}

/*
 * Returns the operating system version, e.g. "5.8".
 */
static VALUE uname_version()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.version);
}

/*
 * Returns the operating system release. e.g. "2.2.16-3".
 */
static VALUE uname_release()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.release);
}

/*
 * Returns the operating system name. e.g. "SunOS".
 */
static VALUE uname_sysname()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.sysname);
}

#ifdef HAVE_SYS_SYSTEMINFO_H
/*
 * Returns the instruction set architecture, e.g. "sparc".
 */
static VALUE uname_architecture()
{
   char buf[BUFSIZE];
   sysinfo(SI_ARCHITECTURE, buf, BUFSIZE);
   return rb_str_new2(buf);
}

/* 
 * Returns the platform identifier. e.g. "SUNW,Sun-Blade-100".
 */
static VALUE uname_platform()
{
   char buf[BUFSIZE];
   sysinfo(SI_PLATFORM, buf, BUFSIZE);
   return rb_str_new2(buf);
}

#ifdef SI_ISALIST
/*
 * Returns a space separated string containing a list of all variant
 * instruction set architectures executable on the current system.
 *  
 * They are listed in order of performance, from best to worst.
*/
static VALUE uname_isalist()
{
   char buf[BUFSIZE];
   sysinfo(SI_ISALIST, buf, BUFSIZE);
   return rb_str_new2(buf);
}
#endif

/*
 * Returns the name of the hardware manufacturer.
 */
static VALUE uname_hw_provider()
{
   char buf[BUFSIZE];
   sysinfo(SI_HW_PROVIDER, buf, BUFSIZE);
   return rb_str_new2(buf);
}

/*
 * Returns the ASCII representation of the hardware-specific serial number
 * of the machine that executes the function.
 */
static VALUE uname_hw_serial()
{
   char buf[BUFSIZE];
   sysinfo(SI_HW_SERIAL, buf, BUFSIZE);
   return rb_Integer(rb_str_new2(buf));
}

/*
 * Returns the name of the Secure Remote Procedure Call domain, if any.
 */
static VALUE uname_srpc_domain()
{
   char buf[BUFSIZE];
   sysinfo(SI_SRPC_DOMAIN, buf, BUFSIZE);
   return rb_str_new2(buf);
}

#ifdef SI_DHCP_CACHE
/*
 * Returns a hexidecimal encoding, in String form, of the name of the
 * interface configured by boot(1M) followed by the DHCPACK reply from
 * the server.
 */
static VALUE uname_dhcp_cache()
{
   char buf[BUFSIZE];
   sysinfo(SI_DHCP_CACHE, buf, BUFSIZE);
   return rb_str_new2(buf);
}
#endif
#endif

#ifdef HAVE_SYSCTL
/*
 * Returns the model type, e.g. "PowerBook5,1"
 */
static VALUE uname_model()
{
   char model[BUFSIZ];
   get_model(model, sizeof(model));
   return rb_str_new2(model);
}
#endif

#if defined(__hpux)
/*
 * Returns the id number, e.g. 234233587. This is a string, not a number.
 */
static VALUE uname_id()
{
   struct utsname u;
   uname(&u);
   return rb_str_new2(u.__idnumber);
}
#endif

/* An interface for returning uname (platform) information. */
void Init_uname()
{
   VALUE mSys, cUname;

   /* The Sys module serves only as a toplevel namespace */
   mSys = rb_define_module("Sys");

   /* The Uname serves as the base class from which system information can
    * be obtained via various class methods.
    */
   cUname = rb_define_class_under(mSys, "Uname", rb_cObject);

   rb_define_singleton_method(cUname, "sysname", uname_sysname, 0);
   rb_define_singleton_method(cUname, "nodename",uname_nodename,0);
   rb_define_singleton_method(cUname, "machine", uname_machine, 0);
   rb_define_singleton_method(cUname, "version", uname_version, 0);
   rb_define_singleton_method(cUname, "release", uname_release, 0);
   rb_define_singleton_method(cUname, "uname", uname_uname_all, 0);

#ifdef HAVE_SYS_SYSTEMINFO_H
   rb_define_singleton_method(cUname, "architecture", uname_architecture, 0);
   rb_define_singleton_method(cUname, "platform", uname_platform, 0);
   rb_define_singleton_method(cUname, "hw_provider", uname_hw_provider, 0);
   rb_define_singleton_method(cUname, "hw_serial_number", uname_hw_serial, 0);
   rb_define_singleton_method(cUname, "srpc_domain", uname_srpc_domain, 0);
#ifdef SI_ISALIST
   rb_define_singleton_method(cUname, "isa_list", uname_isalist, 0);
#endif
#ifdef SI_DHCP_CACHE
   rb_define_singleton_method(cUname, "dhcp_cache", uname_dhcp_cache, 0);
#endif
#endif

#ifdef HAVE_SYSCTL
   rb_define_singleton_method(cUname, "model", uname_model, 0);
#endif

#if defined(__hpux)
   rb_define_singleton_method(cUname, "id_number", uname_id, 0);
#endif

   /* The UnameStruct encapsulates information associated with system
    * information, such as operating system version, release, etc.
    */
   sUname = rb_struct_define("UnameStruct","sysname","nodename",
      "machine","version","release",
#ifdef HAVE_SYS_SYSTEMINFO_H
      "architecture","platform",
#endif

#ifdef HAVE_SYSCTL
      "model",
#endif

#if defined(__hpux)
      "id_number",
#endif
   NULL);

   /* 0.8.4: The version of this library */
   rb_define_const(cUname, "VERSION", rb_str_new2(SYS_UNAME_VERSION));
}

#ifdef __cplusplus
}
#endif
