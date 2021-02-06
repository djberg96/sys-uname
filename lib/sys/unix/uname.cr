module Sys
  class Uname
    lib C
      struct UnameStruct
        sysname : Char*
        nodename : Char*
        release : Char*
        version : Char*
        machine : Char*
        model : Char*
      end

      fun uname(value : UnameStruct) : Int32
    end

    def self.uname
      uname_struct = C::UnameStruct.new

      if C.uname(uname_struct) < 0
        puts "oops"
        puts C.errno
      else
        puts uname_struct
      end
    end
  end
end

Sys::Uname.uname
