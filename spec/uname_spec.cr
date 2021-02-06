require "./spec_helper.cr"

describe System do
  it "correctly reports the operating system name" do
    expected = `uname -s`.chomp
    System.sysname.should eq expected
  end
end
