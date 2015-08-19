if File::ALT_SEPARATOR
  require 'windows/sys/uname'
else
  require 'unix/sys/uname'
end

require 'lib/sys/platform'
