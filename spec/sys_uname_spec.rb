##############################################################################
# sys_uname_spec.rb
#
# Test suite for the sys-uname library. Run 'rake test' to execute tests.
##############################################################################
require 'rspec'
require 'sys/uname'
require 'rbconfig'

RSpec.describe Sys::Uname do
  context "universal singleton methods" do
    example "version constant is set to expected value" do
      expect(Sys::Uname::VERSION).to eql('1.1.1')
      expect(Sys::Uname::VERSION.frozen?).to be(true)
    end

    example "machine singleton method works as expected" do
      expect(described_class).to respond_to(:machine)
      expect{ described_class.machine }.not_to raise_error
      expect(described_class.machine).to be_kind_of(String)
      expect(described_class.machine.size).to be > 0
    end

    example "version singleton method works as expected" do
      expect(described_class).to respond_to(:version)
      expect{ described_class.version }.not_to raise_error
      expect(described_class.version).to be_kind_of(String)
      expect(described_class.version.size).to be > 0
    end

    example "nodename singleton method works as expected" do
      expect(described_class).to respond_to(:nodename)
      expect{ described_class.nodename }.not_to raise_error
      expect(described_class.nodename).to be_kind_of(String)
      expect(described_class.nodename.size).to be > 0
    end

    example "release singleton method works as expected" do
      expect(described_class).to respond_to(:release)
      expect{ described_class.release }.not_to raise_error
      expect(described_class.release).to be_kind_of(String)
      expect(described_class.release.size).to be > 0
    end

    example "sysname singleton method works as expected" do
      expect(described_class).to respond_to(:sysname)
      expect{ described_class.sysname }.not_to raise_error
      expect(described_class.sysname).to be_kind_of(String)
      expect(described_class.sysname.size).to be > 0
    end
  end

  context "singleton methods for Solaris only", :if => RbConfig::CONFIG['host_os'] =~ /sunos|solaris/i do
    example "architecture singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:architecture)
      expect{ described_class.architecture }.not_to raise_error
      expect(described_class.architecture).to be_kind_of(String)
    end

    example "platform singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:platform)
      expect{ described_class.platform }.not_to raise_error
      expect(described_class.platform).to be_kind_of(String)
    end

    example "isa_list singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:isa_list)
      expect{ described_class.isa_list }.not_to raise_error
      expect(described_class.isa_list).to be_kind_of(String)
    end

    example "hw_provider singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:hw_provider)
      expect{ described_class.hw_provider }.not_to raise_error
      expect(described_class.hw_provider).to be_kind_of(String)
    end

    example "hw_serial singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:hw_serial)
      expect{ described_class.hw_serial }.not_to raise_error
      expect(described_class.hw_serial).to be_kind_of(Integer)
    end

    example "srpc_domain singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:srpc_domain)
      expect{ described_class.srpc_domain }.not_to raise_error
      expect(described_class.srpc_domain).to be_kind_of(String)
    end

    example "dhcp_cache singleton method works as expected on solaris" do
      expect(described_class).to respond_to(:dhcp_cache)
      expect{ described_class.dhcp_cache }.not_to raise_error
      expect(described_class.dhcp_cache).to be_kind_of(String)
    end
  end

  context "singleton methods for BSD and Darwin only", :if => RbConfig::CONFIG['host_os'] =~ /darwin|bsd/i do
    example "model singleton method works as expected on BSD and Darwin" do
      expect(described_class).to respond_to(:model)
      expect{ described_class.model }.not_to raise_error
      expect(described_class.model).to be_kind_of(String)
    end
  end

  context "singleton methods for HP-UX only", :if => RbConfig::CONFIG['host_os'] =~ /hpux/i do
    example "id_number singleton method works as expected on HP-UX" do
      expect(described_class).to respond_to(:id_number)
      expect{ described_class.id_number }.not_to raise_error
      expect(described_class.id_number).to be_kind_of(String)
    end
  end

=begin
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

    assert_nothing_raised{ described_class.uname }
    assert_kind_of(Struct, described_class.uname)
    assert_equal(members.sort, described_class.uname.members.sort)
  end

  test "ffi and internal functions are not public" do
    methods = described_class.methods(false).map{ |e| e.to_s }
    assert_false(methods.include?('get_model'))
    assert_false(methods.include?('get_si'))
    assert_false(methods.include?('uname_c'))
    assert_false(methods.include?('sysctl'))
    assert_false(methods.include?('sysinfo'))
  end

  # The following tests are win32 only
  if File::ALT_SEPARATOR
    def test_boot_device
      assert_nothing_raised{ described_class.uname.boot_device }
      assert_kind_of(String, described_class.uname.boot_device)
    end

    def test_build_number
      assert_nothing_raised{ described_class.uname.build_number }
      assert_kind_of(String, described_class.uname.build_number)
    end

    def test_build_type
      assert_nothing_raised{ described_class.uname.build_type }
      assert_kind_of(String, described_class.uname.build_type)
    end

    def test_caption
      assert_nothing_raised{ described_class.uname.caption }
      assert_kind_of(String, described_class.uname.caption)
    end

    def test_code_set
      assert_nothing_raised{ described_class.uname.code_set }
      assert_kind_of(String, described_class.uname.code_set)
    end

    def test_country_code
      assert_nothing_raised{ described_class.uname.country_code }
      assert_kind_of(String, described_class.uname.country_code)
    end

    def test_creation_class_name
      assert_nothing_raised{ described_class.uname.creation_class_name }
      assert_kind_of(String, described_class.uname.creation_class_name)
    end

    def test_cscreation_class_name
      assert_nothing_raised{ described_class.uname.cscreation_class_name }
      assert_kind_of(String, described_class.uname.cscreation_class_name)
    end

    def test_csd_version
      assert_nothing_raised{ described_class.uname.csd_version }
      assert_kind_of([String, NilClass], described_class.uname.csd_version)
    end

    def test_cs_name
      assert_nothing_raised{ described_class.uname.cs_name }
      assert_kind_of(String, described_class.uname.cs_name)
    end

    def test_current_time_zone
      assert_nothing_raised{ described_class.uname.current_time_zone }
      assert_kind_of(Fixnum, described_class.uname.current_time_zone)
    end

    def test_debug
      assert_nothing_raised{ described_class.uname.debug }
      assert_boolean(described_class.uname.debug)
    end

    def test_description
      assert_nothing_raised{ described_class.uname.description }
      assert_kind_of(String, described_class.uname.description)
    end

    def test_distributed
      assert_nothing_raised{ described_class.uname.distributed }
      assert_boolean(described_class.uname.distributed)
    end

    # Not yet supported - WinXP or later only
    #def test_encryption_level
    #   assert_nothing_raised{ described_class.uname.encryption_level }
    #   assert_kind_of(Fixnum,described_class.uname.encryption_level)
    #end

    def test_foreground_application_boost
      assert_nothing_raised{ described_class.uname.foreground_application_boost }
      assert_kind_of(Fixnum, described_class.uname.foreground_application_boost)
    end

    def test_free_physical_memory
      assert_nothing_raised{ described_class.uname.free_physical_memory }
      assert_kind_of(Fixnum, described_class.uname.free_physical_memory)
    end

    def test_free_space_in_paging_files
      assert_nothing_raised{ described_class.uname.free_space_in_paging_files }
      assert_kind_of(Fixnum, described_class.uname.free_space_in_paging_files)
    end

    def test_free_virtual_memory
      assert_nothing_raised{ described_class.uname.free_virtual_memory}
      assert_kind_of(Fixnum, described_class.uname.free_virtual_memory)
    end

    def test_install_date
      assert_nothing_raised{ described_class.uname.install_date}
      assert_kind_of(Time, described_class.uname.install_date)
    end

    # Not yet supported - WinXP or later only
    #def test_large_system_cache
    #   assert_nothing_raised{ described_class.uname.large_system_cache}
    #   assert_kind_of(Time,described_class.uname.large_system_cache)
    #end

    def test_last_bootup_time
      assert_nothing_raised{ described_class.uname.last_bootup_time}
      assert_kind_of(Time, described_class.uname.last_bootup_time)
    end

    def test_local_date_time
      assert_nothing_raised{ described_class.uname.local_date_time}
      assert_kind_of(Time, described_class.uname.local_date_time)
    end

    def test_locale
      assert_nothing_raised{ described_class.uname.locale}
      assert_kind_of(String, described_class.uname.locale)
    end

    def test_manufacturer
      assert_nothing_raised{ described_class.uname.manufacturer}
      assert_kind_of(String, described_class.uname.manufacturer)
    end

    def test_max_number_of_processes
      assert_nothing_raised{ described_class.uname.max_number_of_processes}
      assert_kind_of(Fixnum, described_class.uname.max_number_of_processes)
    end

    def test_max_process_memory_size
      assert_nothing_raised{ described_class.uname.max_process_memory_size}
      assert_kind_of(Integer, described_class.uname.max_process_memory_size)
    end

    def test_name
      assert_nothing_raised{ described_class.uname.name}
      assert_kind_of(String, described_class.uname.name)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_number_of_licensed_users
    #   assert_nothing_raised{ described_class.uname.number_of_licensed_users}
    #   assert_kind_of(Fixnum,described_class.uname.number_of_licensed_users)
    #end

    def test_number_of_processes
      assert_nothing_raised{ described_class.uname.number_of_processes}
      assert_kind_of(Fixnum, described_class.uname.number_of_processes)
    end

    def test_number_of_users
      assert_nothing_raised{ described_class.uname.number_of_users}
      assert_kind_of(Fixnum, described_class.uname.number_of_users)
    end

    def test_organization
      assert_nothing_raised{ described_class.uname.organization}
      assert_kind_of(String, described_class.uname.organization)
    end

    # Eventually replace Fixnum with a string (?)
    def test_os_language
      assert_nothing_raised{ described_class.uname.os_language}
      assert_kind_of(Fixnum, described_class.uname.os_language)
    end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_os_product_suite
    #   assert_nothing_raised{ described_class.uname.os_product_suite}
    #   assert_kind_of(Fixnum,described_class.uname.os_product_suite)
    #end

    def test_os_type
       assert_nothing_raised{ described_class.uname.os_type}
       assert_kind_of(Fixnum, described_class.uname.os_type)
    end

    # Fails?
    #def test_other_type_restriction
    #   assert_nothing_raised{ described_class.uname.other_type_restriction}
    #   assert_kind_of(Fixnum,described_class.uname.other_type_restriction)
    #end

    # Might be nil
    def test_plus_product_id
      assert_nothing_raised{ described_class.uname.plus_product_id }
    end

    # Might be nil
    def test_plus_version_number
      assert_nothing_raised{ described_class.uname.plus_version_number}
    end

    def test_primary
      assert_nothing_raised{ described_class.uname.primary}
      assert_boolean(described_class.uname.primary)
    end

    # Not yet supported - WinXP or later only
    # def test_product_type
    #   assert_nothing_raised{ described_class.uname.product_type}
    #   assert_kind_of(Fixnum,described_class.uname.product_type)
    # end

    def test_quantum_length
      assert_nothing_raised{ described_class.uname.quantum_length}
      assert_kind_of([Fixnum, NilClass], described_class.uname.quantum_length)
    end

    def test_quantum_type
      assert_nothing_raised{ described_class.uname.quantum_type}
      assert_kind_of([Fixnum, NilClass], described_class.uname.quantum_type)
    end

    def test_registered_user
      assert_nothing_raised{ described_class.uname.registered_user}
      assert_kind_of(String, described_class.uname.registered_user)
    end

    def test_serial_number
      assert_nothing_raised{ described_class.uname.serial_number}
      assert_kind_of(String, described_class.uname.serial_number)
    end

    # This is nil on NT 4
    def test_service_pack_major_version
      assert_nothing_raised{ described_class.uname.service_pack_major_version}
      assert_kind_of(Fixnum, described_class.uname.service_pack_major_version)
    end

    # This is nil on NT 4
    def test_service_pack_minor_version
      assert_nothing_raised{ described_class.uname.service_pack_minor_version}
      assert_kind_of(Fixnum, described_class.uname.service_pack_minor_version)
    end

    def test_status
      assert_nothing_raised{ described_class.uname.status}
      assert_kind_of(String, described_class.uname.status)
    end

    # Not yet supported - WinXP or later only
    #def test_suite_mask
    #   assert_nothing_raised{ described_class.uname.suite_mask}
    #   assert_kind_of(String,described_class.uname.suite_mask)
    #end

    def test_system_device
      assert_nothing_raised{ described_class.uname.system_device}
      assert_kind_of(String, described_class.uname.system_device)
    end

    def test_system_directory
      assert_nothing_raised{ described_class.uname.system_directory}
      assert_kind_of(String, described_class.uname.system_directory)
    end

    # Not yet supported - WinXP or later only
    #def test_system_drive
    #   assert_nothing_raised{ described_class.uname.system_drive}
    #   assert_kind_of(String,described_class.uname.system_drive)
    #end

    # Fails on Win XP Pro - returns nil - reason unknown
    #def test_total_swap_space_size
    #   assert_nothing_raised{ described_class.uname.total_swap_space_size}
    #   assert_kind_of(Fixnum,described_class.uname.total_swap_space_size)
    #end

    def test_total_virtual_memory_size
      assert_nothing_raised{ described_class.uname.total_virtual_memory_size}
      assert_kind_of(Fixnum, described_class.uname.total_virtual_memory_size)
    end

    def test_total_visible_memory_size
      assert_nothing_raised{ described_class.uname.total_visible_memory_size}
      assert_kind_of(Fixnum, described_class.uname.total_visible_memory_size)
    end

    def test_version
      assert_nothing_raised{ described_class.uname.version}
      assert_kind_of(String, described_class.uname.version)
    end

    def test_windows_directory
      assert_nothing_raised{ described_class.uname.windows_directory}
      assert_kind_of(String, described_class.uname.windows_directory)
    end
  end
=end
end
