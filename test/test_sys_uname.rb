##############################################################################
# test_sys_uname.rb
#
# Test suite for the sys-uname library. Run 'rake test' to execute tests.
##############################################################################
require 'test-unit'
require 'sys/uname'
require 'rbconfig'
include Sys

class TC_Sys_Uname < Test::Unit::TestCase
  def self.startup
    @@host_os = RbConfig::CONFIG['host_os']
  end

  test "version constant is set to expected value" do
    assert_equal('1.0.3', Uname::VERSION)
  end

  test "machine singleton method works as expected" do
    assert_respond_to(Uname, :machine)
    assert_nothing_raised{ Uname.machine }
    assert_kind_of(String, Uname.machine)
    assert_true(Uname.machine.size > 0)
  end

  test "version singleton method works as expected" do
    assert_respond_to(Uname, :version)
    assert_nothing_raised{ Uname.version }
    assert_kind_of(String, Uname.version)
    assert_true(Uname.version.size > 0)
  end

  test "nodename singleton method works as expected" do
    assert_respond_to(Uname, :nodename)
    assert_nothing_raised{ Uname.nodename }
    assert_kind_of(String, Uname.nodename)
    assert_true(Uname.nodename.size > 0)
  end

  test "release singleton method works as expected" do
    assert_respond_to(Uname, :release)
    assert_nothing_raised{ Uname.release }
    assert_kind_of(String, Uname.release)
    assert_true(Uname.release.size > 0)
  end

  test "sysname singleton method works as expected" do
    assert_respond_to(Uname, :sysname)
    assert_nothing_raised{ Uname.sysname }
    assert_kind_of(String, Uname.sysname)
    assert_true(Uname.sysname.size > 0)
  end

  test "architecture singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :architecture)
    assert_nothing_raised{ Uname.architecture }
    assert_kind_of(String, Uname.architecture)
  end

  test "platform singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :platform)
    assert_nothing_raised{ Uname.platform }
    assert_kind_of(String, Uname.platform)
  end

  test "isa_list singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :isa_list)
    assert_nothing_raised{ Uname.isa_list }
    assert_kind_of(String, Uname.isa_list)
  end

  test "hw_provider singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname,:hw_provider)
    assert_nothing_raised{ Uname.hw_provider }
    assert_kind_of(String, Uname.hw_provider)
  end

  test "hw_serial singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :hw_serial)
    assert_nothing_raised{ Uname.hw_serial }
    assert_kind_of(Integer, Uname.hw_serial)
  end

  test "srpc_domain singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :srpc_domain)
    assert_nothing_raised{ Uname.srpc_domain }
    assert_kind_of(String, Uname.srpc_domain)
  end

  test "dhcp_cache singleton method works as expected on solaris" do
    omit_unless(@@host_os =~ /sunos|solaris/i, "Solaris only")
    assert_respond_to(Uname, :dhcp_cache)
    assert_nothing_raised{ Uname.dhcp_cache }
    assert_kind_of(String, Uname.dhcp_cache)
  end

  test "model singleton method works as expected on BSD and Darwin" do
    omit_unless(@@host_os =~ /darwin|powerpc|bsd|mach/i, "BSD/Darwin only")
    assert_respond_to(Uname, :model)
    assert_nothing_raised{ Uname.model }
    assert_kind_of(String, Uname.model)
  end

  test "id_number singleton method works as expected on HP-UX" do
    omit_unless(@@host_os =~ /hpux/i, "HP-UX only")
    assert_respond_to(Uname, :id_number)
    assert_nothing_raised{ Uname.id_number }
    assert_kind_of(String, Uname.id_number)
  end

  test "uname struct contains expected members based on platform" do
    members = %w/sysname nodename machine version release/
    case RbConfig::CONFIG['host_os']
      when /linux/i
        members.push('domainname')
      when /sunos|solaris/i
        members.push(
          'architecture', 'platform', 'hw_serial', 'hw_provider',
          'srpc_domain', 'isa_list', 'dhcp_cache'
        )
      when /powerpc|darwin|bsd/i
        members.push('model')
      when /hpux/i
        members.push('id')
      when /win32|mingw|cygwin|dos|windows/i
        members = %w[
          boot_device build_number build_type caption code_set country_code
          creation_class_name cscreation_class_name csd_version cs_name
          current_time_zone debug description distributed
          foreground_application_boost free_physical_memory
          free_space_in_paging_files free_virtual_memory
          install_date last_bootup_time local_date_time locale
          manufacturer max_number_of_processes max_process_memory_size
          name number_of_licensed_users number_of_processes
          number_of_users organization os_language os_product_suite
          os_type other_type_description plus_product_id
          plus_version_number primary quantum_length quantum_type
          registered_user serial_number service_pack_major_version
          service_pack_minor_version size_stored_in_paging_files
          status system_device system_directory total_swap_space_size
          total_virtual_memory_size total_visible_memory_size version
          windows_directory
        ]
    end

    members.map!{ |e| e.to_sym } if RUBY_VERSION.to_f >= 1.9

    assert_nothing_raised{ Uname.uname }
    assert_kind_of(Struct, Uname.uname)
    assert_equal(members.sort, Uname.uname.members.sort)
  end

  test "ffi and internal functions are not public" do
    methods = Uname.methods(false).map{ |e| e.to_s }
    assert_false(methods.include?('get_model'))
    assert_false(methods.include?('get_si'))
    assert_false(methods.include?('uname_c'))
    assert_false(methods.include?('sysctl'))
    assert_false(methods.include?('sysinfo'))
  end

  # The following tests are win32 only
  if File::ALT_SEPARATOR
    def test_boot_device
      assert_nothing_raised{ Uname.uname.boot_device }
      assert_kind_of(String, Uname.uname.boot_device)
    end

    def test_build_number
      assert_nothing_raised{ Uname.uname.build_number }
      assert_kind_of(String, Uname.uname.build_number)
    end

    def test_build_type
      assert_nothing_raised{ Uname.uname.build_type }
      assert_kind_of(String, Uname.uname.build_type)
    end

    def test_caption
      assert_nothing_raised{ Uname.uname.caption }
      assert_kind_of(String, Uname.uname.caption)
    end

    def test_code_set
      assert_nothing_raised{ Uname.uname.code_set }
      assert_kind_of(String, Uname.uname.code_set)
    end

    def test_country_code
      assert_nothing_raised{ Uname.uname.country_code }
      assert_kind_of(String, Uname.uname.country_code)
    end

    def test_creation_class_name
      assert_nothing_raised{ Uname.uname.creation_class_name }
      assert_kind_of(String, Uname.uname.creation_class_name)
    end

    def test_cscreation_class_name
      assert_nothing_raised{ Uname.uname.cscreation_class_name }
      assert_kind_of(String, Uname.uname.cscreation_class_name)
    end

    def test_csd_version
      assert_nothing_raised{ Uname.uname.csd_version }
      assert_kind_of([String, NilClass], Uname.uname.csd_version)
    end

    def test_cs_name
      assert_nothing_raised{ Uname.uname.cs_name }
      assert_kind_of(String, Uname.uname.cs_name)
    end

    def test_current_time_zone
      assert_nothing_raised{ Uname.uname.current_time_zone }
      assert_kind_of(Fixnum, Uname.uname.current_time_zone)
    end

    def test_debug
      assert_nothing_raised{ Uname.uname.debug }
      assert_boolean(Uname.uname.debug)
    end

    def test_description
      assert_nothing_raised{ Uname.uname.description }
      assert_kind_of(String, Uname.uname.description)
    end

    def test_distributed
      assert_nothing_raised{ Uname.uname.distributed }
      assert_boolean(Uname.uname.distributed)
    end

    # Not yet supported - WinXP or later only
    #def test_encryption_level
    #   assert_nothing_raised{ Uname.uname.encryption_level }
    #   assert_kind_of(Fixnum,Uname.uname.encryption_level)
    #end

    def test_foreground_application_boost
      assert_nothing_raised{ Uname.uname.foreground_application_boost }
      assert_kind_of(Fixnum, Uname.uname.foreground_application_boost)
    end

    def test_free_physical_memory
      assert_nothing_raised{ Uname.uname.free_physical_memory }
      assert_kind_of(Fixnum, Uname.uname.free_physical_memory)
    end

    def test_free_space_in_paging_files
      assert_nothing_raised{ Uname.uname.free_space_in_paging_files }
      assert_kind_of(Fixnum, Uname.uname.free_space_in_paging_files)
    end

    def test_free_virtual_memory
      assert_nothing_raised{ Uname.uname.free_virtual_memory}
      assert_kind_of(Fixnum, Uname.uname.free_virtual_memory)
    end

    def test_install_date
      assert_nothing_raised{ Uname.uname.install_date}
      assert_kind_of(Time, Uname.uname.install_date)
    end

    # Not yet supported - WinXP or later only
    #def test_large_system_cache
    #   assert_nothing_raised{ Uname.uname.large_system_cache}
    #   assert_kind_of(Time,Uname.uname.large_system_cache)
    #end

    def test_last_bootup_time
      assert_nothing_raised{ Uname.uname.last_bootup_time}
      assert_kind_of(Time, Uname.uname.last_bootup_time)
    end

    def test_local_date_time
      assert_nothing_raised{ Uname.uname.local_date_time}
      assert_kind_of(Time, Uname.uname.local_date_time)
    end

    def test_locale
      assert_nothing_raised{ Uname.uname.locale}
      assert_kind_of(String, Uname.uname.locale)
    end

    def test_manufacturer
      assert_nothing_raised{ Uname.uname.manufacturer}
      assert_kind_of(String, Uname.uname.manufacturer)
    end

    def test_max_number_of_processes
      assert_nothing_raised{ Uname.uname.max_number_of_processes}
      assert_kind_of(Fixnum, Uname.uname.max_number_of_processes)
    end

    def test_max_process_memory_size
      assert_nothing_raised{ Uname.uname.max_process_memory_size}
      assert_kind_of(Integer, Uname.uname.max_process_memory_size)
    end

    def test_name
      assert_nothing_raised{ Uname.uname.name}
      assert_kind_of(String, Uname.uname.name)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_number_of_licensed_users
    #   assert_nothing_raised{ Uname.uname.number_of_licensed_users}
    #   assert_kind_of(Fixnum,Uname.uname.number_of_licensed_users)
    #end

    def test_number_of_processes
      assert_nothing_raised{ Uname.uname.number_of_processes}
      assert_kind_of(Fixnum, Uname.uname.number_of_processes)
    end

    def test_number_of_users
      assert_nothing_raised{ Uname.uname.number_of_users}
      assert_kind_of(Fixnum, Uname.uname.number_of_users)
    end

    def test_organization
      assert_nothing_raised{ Uname.uname.organization}
      assert_kind_of(String, Uname.uname.organization)
    end

    # Eventually replace Fixnum with a string (?)
    def test_os_language
      assert_nothing_raised{ Uname.uname.os_language}
      assert_kind_of(Fixnum, Uname.uname.os_language)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_os_product_suite
    #   assert_nothing_raised{ Uname.uname.os_product_suite}
    #   assert_kind_of(Fixnum,Uname.uname.os_product_suite)
    #end

    def test_os_type
       assert_nothing_raised{ Uname.uname.os_type}
       assert_kind_of(Fixnum, Uname.uname.os_type)
    end

    # Fails?
    #def test_other_type_restriction
    #   assert_nothing_raised{ Uname.uname.other_type_restriction}
    #   assert_kind_of(Fixnum,Uname.uname.other_type_restriction)
    #end

    # Might be nil
    def test_plus_product_id
      assert_nothing_raised{ Uname.uname.plus_product_id }
    end

    # Might be nil
    def test_plus_version_number
      assert_nothing_raised{ Uname.uname.plus_version_number}
    end

    def test_primary
      assert_nothing_raised{ Uname.uname.primary}
      assert_boolean(Uname.uname.primary)
    end

    # Not yet supported - WinXP or later only
    # def test_product_type
    #   assert_nothing_raised{ Uname.uname.product_type}
    #   assert_kind_of(Fixnum,Uname.uname.product_type)
    # end

    def test_quantum_length
      assert_nothing_raised{ Uname.uname.quantum_length}
      assert_kind_of([Fixnum, NilClass], Uname.uname.quantum_length)
    end

    def test_quantum_type
      assert_nothing_raised{ Uname.uname.quantum_type}
      assert_kind_of([Fixnum, NilClass], Uname.uname.quantum_type)
    end

    def test_registered_user
      assert_nothing_raised{ Uname.uname.registered_user}
      assert_kind_of(String, Uname.uname.registered_user)
    end

    def test_serial_number
      assert_nothing_raised{ Uname.uname.serial_number}
      assert_kind_of(String, Uname.uname.serial_number)
    end

    # This is nil on NT 4
    def test_service_pack_major_version
      assert_nothing_raised{ Uname.uname.service_pack_major_version}
      assert_kind_of(Fixnum, Uname.uname.service_pack_major_version)
    end

    # This is nil on NT 4
    def test_service_pack_minor_version
      assert_nothing_raised{ Uname.uname.service_pack_minor_version}
      assert_kind_of(Fixnum, Uname.uname.service_pack_minor_version)
    end

    def test_status
      assert_nothing_raised{ Uname.uname.status}
      assert_kind_of(String, Uname.uname.status)
    end

    # Not yet supported - WinXP or later only
    #def test_suite_mask
    #   assert_nothing_raised{ Uname.uname.suite_mask}
    #   assert_kind_of(String,Uname.uname.suite_mask)
    #end

    def test_system_device
      assert_nothing_raised{ Uname.uname.system_device}
      assert_kind_of(String, Uname.uname.system_device)
    end

    def test_system_directory
      assert_nothing_raised{ Uname.uname.system_directory}
      assert_kind_of(String, Uname.uname.system_directory)
    end

    # Not yet supported - WinXP or later only
    #def test_system_drive
    #   assert_nothing_raised{ Uname.uname.system_drive}
    #   assert_kind_of(String,Uname.uname.system_drive)
    #end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_total_swap_space_size
    #   assert_nothing_raised{ Uname.uname.total_swap_space_size}
    #   assert_kind_of(Fixnum,Uname.uname.total_swap_space_size)
    #end

    def test_total_virtual_memory_size
      assert_nothing_raised{ Uname.uname.total_virtual_memory_size}
      assert_kind_of(Fixnum, Uname.uname.total_virtual_memory_size)
    end

    def test_total_visible_memory_size
      assert_nothing_raised{ Uname.uname.total_visible_memory_size}
      assert_kind_of(Fixnum, Uname.uname.total_visible_memory_size)
    end

    def test_version
      assert_nothing_raised{ Uname.uname.version}
      assert_kind_of(String, Uname.uname.version)
    end

    def test_windows_directory
      assert_nothing_raised{ Uname.uname.windows_directory}
      assert_kind_of(String, Uname.uname.windows_directory)
    end
  end
end
