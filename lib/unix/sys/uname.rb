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

    # :stopdoc

    CTL_HW   = 6   # Generic hardware/cpu
    HW_MODEL = 2   # Specific machine model
    BUFSIZ   = 256 # Buffer size for strings

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
        :sysname,  [:char, BUFSIZ],
        :nodename, [:char, BUFSIZ],
        :release,  [:char, BUFSIZ],
        :version,  [:char, BUFSIZ],
        :machine,  [:char, BUFSIZ]
      ]

      case Config::CONFIG['host_os']
        when /sunos|solaris/i
          members.push(:architecture, [:char, BUFSIZ])
          members.push(:platform, [:char, BUFSIZ])
        when /hpux/i
          members.push(:__id_number, [:char, BUFSIZ])
      end

      layout(*members)
    end

    # :startdoc:

    # Returns a struct that contains the sysname, nodename, machine, version
    # and release of your system.
    #
    # On OS X it will also include the model.
    #
    # On Solaris, it will also include the architecture and platform.
    #
    # On HP-UX, it will also include the id_number.
    #
    # Example:
    #
    #   require 'sys/uname'
    #
    #   p Sys::Uname.uname
    # 
    def self.uname
      utsname = UnameFFIStruct.new
      uname_c(utsname)

      struct = OpenStruct.new
      struct.sysname  = utsname[:sysname].to_s
      struct.nodename = utsname[:nodename].to_s
      struct.release  = utsname[:release].to_s
      struct.version  = utsname[:version].to_s
      struct.machine  = utsname[:machine].to_s

      if defined? :sysctl
        struct.model = get_model()
      end

      case Config::CONFIG['host_os']
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
      
    # Returns the name of this implementation of the operating system.
    #
    # Example:
    #
    #  Uname.sysname # => 'SunOS'
    #
    def self.sysname
      uname.sysname
    end
      
    # Returns the name of this node within the communications network to
    # which this node is attached, if any. This is often, but not
    # necessarily, the same as the host name.
    #
    # Example:
    #
    #  Uname.nodename # => 'your_host.foo.com'
    # 
    def self.nodename
      uname.nodename
    end
      
    # Returns the current release level of your operating system.
    #
    # Example:
    #
    #  Uname.release # => '2.2.16-3'
    #
    def self.release
      uname.release
    end
      
    # Returns the current version level of your operating system.
    #
    # Example:
    #
    #  Uname.version # => '5.9'
    #
    def self.version
      uname.version
    end
      
    # Returns the machine hardware type.
    #
    # Example:
    #
    #  Uname.machine # => 'i686'
    #
    def self.machine
      uname.machine
    end
      
    if defined? :sysctl
      # Returns the model type.
      #
      # Example:
      #
      #  Uname.model # => 'MacBookPro5,3'
      #
      def self.model
        uname.model
      end
    end


    # TODO: Add platform, architecture and id_number methods

    if Config::CONFIG['host_os'] =~ /sunos|solaris/i
    end

    if Config::CONFIG['host_os'] =~ /hpux/i
    end

    private

    # Returns the model for systems that define sysctl().
    #
    def self.get_model
      buf  = 0.chr * BUFSIZ
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MODEL])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end
  end
end
