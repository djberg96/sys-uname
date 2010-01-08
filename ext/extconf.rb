require 'mkmf'

# Linux has sysctl, but not the expected mibs
unless RUBY_PLATFORM.match('linux')
   have_func('sysctl')
end

if RUBY_PLATFORM =~ /sunos|solaris/i
   have_header('sys/systeminfo.h')
end

create_makefile('sys/uname', 'sys')
