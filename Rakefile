require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Clean the build files for the sys-uname source for UNIX systems"
task :clean do
   Dir.chdir('ext') do
      unless CONFIG['host_os'] =~ /mswin|windows/i
         build_file = 'uname.' + Config::CONFIG['DLEXT']
         rm "sys/#{build_file}" if File.exists?("sys/#{build_file}")
         sh 'make distclean' if File.exists?(build_file)
      end
   end
end

desc "Build the sys-uname package on UNIX systems (but don't install it)"
task :build => [:clean] do
   Dir.chdir('ext') do
      unless CONFIG['host_os'] =~ /mswin|windows/i
         ruby 'extconf.rb'
         sh 'make'
         build_file = 'uname.' + Config::CONFIG['DLEXT']
         cp build_file, 'sys' # For testing
      end
   end
end

desc "Run the example program"
task :example => [:build] do
   if CONFIG['host_os'] =~ /mswin|windows/i
      sh 'ruby -Ilib examples/uname_test.rb'
   else
      sh 'ruby -Iext examples/uname_test.rb'
   end
end

if CONFIG['host_os'] =~ /mswin|windows/i
   desc "Install the sys-uname package (non-gem)"
   task :install do
      Dir.mkdir(dir) unless File.exists?(dir)
      FileUtils.cp('lib/sys/uname.rb', dir, :verbose => true)
   end
else
   desc "Install the sys-uname package"
   task :install => [:build] do
      Dir.chdir('ext') do
         sh 'make install'
      end
   end
end

desc "Install the sys-uname package as a gem"
task :install_gem do
   ruby 'sys-uname.gemspec'
   file = Dir['sys-uname*.gem'].first
   sh "gem install #{file}"
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
   if CONFIG['host_os'] =~ /mswin|windows/i
      t.libs << 'lib'
   else
      task :test => :build
      t.libs << 'ext'
      t.libs.delete('lib')
   end
end
