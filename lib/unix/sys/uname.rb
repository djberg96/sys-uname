require 'ffi'
require 'rbconfig'

# The Sys module serves as a namespace only.
module Sys
  # The Uname class encapsulates information about the system.
  class Uname
    extend FFI::Library
      
    # The version of the sys-uname library
    VERSION = '0.9.0'

    attach_function :uname, [:pointer], :int

    # Temporarily remove the uname method to avoid function name conflict
    class << self
      alias :uname_c :uname
      remove_method :uname
    end
      
    class UnameFFIStruct < FFI::Struct
      layout(
        :sysname,  [:char, 256],
        :nodename, [:char, 256],
        :release,  [:char, 256],
        :version,  [:char, 256],
        :machine,  [:char, 256]
      )
    end

    UnameStruct = Struct.new(
      'UnameStruct',
      :sysname,
      :nodename,
      :release,
      :version,
      :machine
    )

    def self.uname
      utsname = UnameFFIStruct.new
      uname_c(utsname)

      UnameStruct.new(
        utsname[:sysname],
        utsname[:nodename],
        utsname[:release],
        utsname[:version],
        utsname[:machine]
      )
    end
      
    def self.sysname
      uname[:sysname]         
    end
      
    def self.nodename
      uname[:nodename]         
    end
      
    def self.release
      uname[:release]         
    end
      
    def self.version
      uname[:version]         
    end
      
    def self.machine
      uname[:machine]         
    end
      
    def self.model
      uname[:model]         
    end
  end
end
