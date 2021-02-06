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

  def self.uname
    uname_struct = LibC::Uname.new

    if LibC.uname(pointerof(uname_struct)) < 0
      raise "uname function call failed"
    else
      Uname.new(uname_struct)
    end
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
end
