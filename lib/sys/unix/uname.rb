require 'ffi'
require 'rbconfig'
require 'ostruct'

# The Sys module serves as a namespace only.
module Sys
  # The Uname class encapsulates information about the system.
  class Uname
    extend FFI::Library
    ffi_lib FFI::Library::LIBC

    # Error raised if the uname() function fails.
    class Error < StandardError; end

    # :stopdoc

    # Buffer size for uname struct char arrays
    case RbConfig::CONFIG['host_os']
      when /linux/i
        BUFSIZE = 65
      when /bsd/i
        BUFSIZE = 32 # TODO: version method chopped
      when /sunos|solaris/i
        BUFSIZE = 257
      else
        BUFSIZE = 256
    end

    attach_function :uname_c, :uname, [:pointer], :int
    private_class_method :uname_c

    begin
      attach_function :sysctl, [:pointer, :uint, :pointer, :pointer, :pointer, :size_t], :int
      private_class_method :sysctl

      CTL_HW   = 6   # Generic hardware/cpu
      HW_MODEL = 2   # Specific machine model
    rescue FFI::NotFoundError
      # Ignore. Not suppored.
    end

    begin
      attach_function :sysinfo, [:int, :pointer, :long], :long
      private_class_method :sysinfo

      SI_SYSNAME      = 1   # OS name
      SI_HOSTNAME     = 2   # Node name
      SI_RELEASE      = 3   # Operating system release
      SI_VERSION      = 4   # Version field of utsname
      SI_MACHINE      = 5   # Machine type
      SI_ARCHITECTURE = 6   # Instruction set architecture
      SI_HW_SERIAL    = 7   # Hardware serial number
      SI_HW_PROVIDER  = 8   # Hardware manufacturer
      SI_SRPC_DOMAIN  = 9   # Secure RPC domain
      SI_PLATFORM     = 513 # Platform identifier
      SI_ISALIST      = 514 # Supported isalist
      SI_DHCP_CACHE   = 515 # Kernel cached DHCPACK
    rescue FFI::NotFoundError
      # Ignore. Not suppored.
    end

    class UnameFFIStruct < FFI::Struct
      members = [
        :sysname,  [:char, BUFSIZE],
        :nodename, [:char, BUFSIZE],
        :release,  [:char, BUFSIZE],
        :version,  [:char, BUFSIZE],
        :machine,  [:char, BUFSIZE]
      ]

      if RbConfig::CONFIG['host_os'] =~ /linux/i
        members.push(:domainname, [:char, BUFSIZE])
      end

      if RbConfig::CONFIG['host_os'] =~ /hpux/i
        members.push(:__id_number, [:char, BUFSIZE])
      end

      layout(*members)
    end

    fields = %w[
      sysname
      nodename
      release
      version
      machine
    ]

    if RbConfig::CONFIG['host_os'] =~ /linux/i
      fields.push('domainname')
    end

    if RbConfig::CONFIG['host_os'] =~ /hpux/i
      fields.push('id_number')
    end

    if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
      fields.push(
        'architecture',
        'dhcp_cache',
        'hw_provider',
        'hw_serial',
        'isa_list',
        'platform',
        'srpc_domain'
      )
    end

    if RbConfig::CONFIG['host_os'] =~ /darwin|bsd/i
      fields.push('model')
    end

    # :startdoc:

    UnameStruct = Struct.new("UnameStruct", *fields)

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

      if uname_c(utsname) < 0
        raise Error, "uname() function call failed"
      end

      struct = UnameStruct.new
      struct[:sysname]  = utsname[:sysname].to_s
      struct[:nodename] = utsname[:nodename].to_s
      struct[:release]  = utsname[:release].to_s
      struct[:version]  = utsname[:version].to_s
      struct[:machine]  = utsname[:machine].to_s

      if RbConfig::CONFIG['host_os'] =~ /darwin|bsd/i
        struct[:model] = get_model()
      end

      if RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i
        struct[:architecture] = get_si(SI_ARCHITECTURE)
        struct[:platform]     = get_si(SI_PLATFORM)
        struct[:hw_serial]    = get_si(SI_HW_SERIAL)
        struct[:hw_provider]  = get_si(SI_HW_PROVIDER)
        struct[:srpc_domain]  = get_si(SI_SRPC_DOMAIN)
        struct[:isa_list]     = get_si(SI_ISALIST)
        struct[:dhcp_cache]   = get_si(SI_DHCP_CACHE)

        # FFI and Solaris don't get along so well, so we try again
        struct[:sysname]  = get_si(SI_SYSNAME) if struct.sysname.empty?
        struct[:nodename] = get_si(SI_HOSTNAME) if struct.nodename.empty?
        struct[:release]  = get_si(SI_RELEASE) if struct.release.empty?
        struct[:version]  = get_si(SI_VERSION) if struct.version.empty?
        struct[:machine]  = get_si(SI_MACHINE) if struct.machine.empty?
      end

      if RbConfig::CONFIG['host_os'] =~ /hpux/i
        struct[:id_number] = utsname[:__id_number].to_s
      end

      if RbConfig::CONFIG['host_os'] =~ /linux/i
        struct[:domainname] = utsname[:domainname].to_s
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

    private

    # Returns the model for systems that define sysctl().
    #
    def self.get_model
      buf  = 0.chr * BUFSIZE
      mib  = FFI::MemoryPointer.new(:int, 2).write_array_of_int([CTL_HW, HW_MODEL])
      size = FFI::MemoryPointer.new(:long, 1).write_int(buf.size)

      sysctl(mib, 2, buf, size, nil, 0)

      buf.strip
    end

    private_class_method :get_model

    # Returns the various sysinfo information based on +flag+.
    #
    def self.get_si(flag)
      buf = 0.chr * BUFSIZE
      sysinfo(flag, buf, BUFSIZE)
      buf.strip
    end

    private_class_method :get_si
  end

  %w[sysname nodename release version machine].each do |f|
    Uname.define_singleton_method(f.to_sym) { uname.send(f) }
  end

  Uname.define_singleton_method(:model) { uname.send(:model) } if defined? :sysctl

  if defined? :sysinfo
    %w[architecture platform dhcp_cache isa_list hw_provider model srpc_domain].each do |f|
      Uname.define_singleton_method(f.to_sym) { uname.send(f) }
    end
  end
end
