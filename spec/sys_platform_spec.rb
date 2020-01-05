##############################################################################
# sys_platform_spec.rb
#
# Test suite for the Sys::Platform class.
##############################################################################
require 'rspec'
require 'sys/uname'
require 'rbconfig'

RSpec.describe Sys::Platform do
  let(:host_os){ RbConfig::CONFIG['host_os'] }
  let(:windows){ RbConfig::CONFIG['host_os'] =~ /mingw|mswin|windows/i ? true : false }

  example "the VERSION constant is set to the expected value" do
    expect(Sys::Platform::VERSION).to eql('1.2.0')
    expect(Sys::Platform::VERSION).to be_frozen
  end

=begin
  test "the ARCH constant is defined" do
    assert_kind_of(Symbol, Sys::Platform::ARCH)
  end

  test "the OS constant is defined" do
    assert_kind_of(Symbol, Sys::Platform::OS)
  end

  test "the IMPL constant is defined" do
    assert_kind_of(Symbol, Sys::Platform::IMPL)
  end

  test "the IMPL returns an expected value" do
    omit_unless(@@windows)
    assert_true([:mingw, :mswin].include?(Sys::Platform::IMPL))
  end

  test "the mac? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :mac?)
    assert_boolean(Sys::Platform.mac?)
  end

  test "the windows? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :windows?)
    assert_boolean(Sys::Platform.windows?)
  end

  test "the windows? method returns the expected value" do
    assert_equal(Sys::Platform.windows?, @@windows)
  end

  test "the unix? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :unix?)
    assert_boolean(Sys::Platform.unix?)
  end

  test "the unix? method returns the expected value" do
    assert_equal(Sys::Platform.unix?, !@@windows)
  end

  test "the solaris? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :solaris?)
    assert_boolean(Sys::Platform.solaris?)
  end

  test "the linux? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :linux?)
    assert_boolean(Sys::Platform.linux?)
  end

  test "the bsd? method is defined and returns a boolean" do
    assert_respond_to(Sys::Platform, :bsd?)
    assert_boolean(Sys::Platform.bsd?)
  end
=end
end
