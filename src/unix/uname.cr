module System
  lib LibC
    struct Uname
      sysname : ::LibC::Char[256]
      nodename : ::LibC::Char[256]
      release : ::LibC::Char[256]
      version : ::LibC::Char[256]
      machine : ::LibC::Char[256]
    end

    fun uname(value : Uname*) : Int32
  end

  struct Uname
    getter cstruct

    def initialize(@cstruct : LibC::Uname)
    end

    macro get(*props)
      {% for prop in props %}
        def {{prop}}
          String.new(cstruct.{{prop}}.to_unsafe)
        end
      {% end %}
    end

    get sysname, nodename, release, version, machine
  end

  # Returns a `System::Uname` struct that has the following members:
  #
  # * sysname
  # * nodename
  # * release
  # * version
  # * machine
  #
  def self.uname : System::Uname
    uname_struct = LibC::Uname.new

    if LibC.uname(pointerof(uname_struct)) < 0
      raise "uname function call failed"
    else
      Uname.new(uname_struct)
    end
  end

  # Returns the operating system name.
  #
  def self.sysname : String
    uname.sysname
  end

  # Returns the nodename, i.e. the name it's known by on the network.
  # Typically identical to the hostname.
  #
  def self.nodename : String
    uname.nodename
  end

  # Returns the operating system release.
  #
  def self.release : String
    uname.release
  end

  # Returns the operating system version.
  #
  def self.version : String
    uname.version
  end

  # Returns the machine hardware name.
  #
  def self.machine : String
    uname.machine
  end
end
