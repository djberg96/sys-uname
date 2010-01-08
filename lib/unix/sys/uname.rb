require 'ffi'
require 'rbconfig'
require 'ostruct'

# The Sys module serves as a namespace only.
module Sys
  # The Uname class encapsulates information about the system.
  class Uname
    extend FFI::Library
      
    # The version of the sys-uname library
    VERSION = '0.9.0'

    attach_function :uname, [:pointer], :int

    begin
      attach_function :sysctl, [:pointer, :uint, :pointer, :pointer, :pointer, :size_t], :int
    rescue FFI::Exception
      # Ignore. Not suppored.
    end

    # Temporarily remove the uname method to avoid function name conflict
    class << self
      alias :uname_c :uname
      remove_method :uname
    end
      
    class UnameFFIStruct < FFI::Struct
      members = [
        :sysname,  [:char, 256],
        :nodename, [:char, 256],
        :release,  [:char, 256],
        :version,  [:char, 256],
        :machine,  [:char, 256]
      ]

      case Config::CONFIG['host_os']
        when /sunos|solaris/i
          members.push(:architecture, [:char, 256])
          members.push(:platform, [:char, 256])
        when /hpux/i
          members.push(:__id_number, [:char, 256])
      end

      layout(*members)
    end

    def self.uname
      utsname = UnameFFIStruct.new
      uname_c(utsname)

      struct = OpenStruct.new
      struct.sysname  = utsname[:sysname].to_s
      struct.nodename = utsname[:nodename].to_s
      struct.release  = utsname[:release].to_s
      struct.version  = utsname[:version].to_s
      struct.machine  = utsname[:machine].to_s

      case Config::CONFIG['host_os']
        when /darwin/i
          struct.model = get_model
        when /sunos|solaris/i
          struct.architecture = utsname[:architecture].to_s
          struct.platform = utsname[:platform].to_s
        when /hpux/i
          struct.id_number = utsname[:__id_number].to_s
      end

      # Let's add a members method that works for testing and compatibility
      if struct.members.nil?
        struct.instance_eval(%Q{
          def members
            @table.keys.map{ |k| k.to_s }
          end
        })
      end

      struct.freeze
    end
      
    def self.sysname
      uname.sysname
    end
      
    def self.nodename
      uname.nodename
    end
      
    def self.release
      uname.release
    end
      
    def self.version
      uname.version
    end
      
    def self.machine
      uname.machine
    end
      
    def self.model
      uname.model
    end

    private

    # TODO: Implement
    def get_model
      size_t sz = n;
      int mib[2];
 
      mib[0] = CTL_HW;
      mib[1] = HW_MODEL;
      return sysctl(mib, 2, buf, &sz, NULL, 0);
    end
  end
end
