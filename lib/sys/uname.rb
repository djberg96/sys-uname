if File::ALT_SEPARATOR
  require_relative 'windows/uname'
else
  require_relative 'unix/uname'
end

require_relative 'platform'
