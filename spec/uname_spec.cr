require "./spec_helper.cr"

describe System do
  it "correctly reports the operating system name" do
    expected = `uname -s`.chomp
    System.sysname.should eq(expected)
  end

  it "correctly reports the nodename" do
    expected = `uname -n`.chomp
    System.nodename.should eq(expected)
  end

  it "correctly reports the machine name" do
    expected = `uname -m`.chomp
    System.machine.should eq(expected)
  end

  it "correctly reports the release name" do
    expected = `uname -r`.chomp
    System.release.should eq(expected)
  end

  it "correctly reports the version" do
    expected = `uname -v`.chomp
    System.version.should eq(expected)
  end

  it "returns a struct if the uname method is used" do
    System.uname.should be_a(System::Uname)
  end
end
