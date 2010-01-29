require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Clean the build files for the sys-uname source for UNIX systems"
task :clean do
  Dir.chdir('ext') do
    unless CONFIG['host_os'] =~ /mswin|windows|mingw|cygwin|dos/i
      build_file = 'uname.' + Config::CONFIG['DLEXT']
      rm "sys/#{build_file}" if File.exists?("sys/#{build_file}")
      sh 'make distclean' if File.exists?(build_file)
    end
  end
end

desc "Build the sys-uname library on UNIX systems (but don't install it)"
task :build => [:clean] do
  Dir.chdir('ext') do
    unless CONFIG['host_os'] =~ /mswin|windows|mingw|cygwin|dos/i
      ruby 'extconf.rb'
      sh 'make'
      build_file = 'uname.' + Config::CONFIG['DLEXT']
      cp build_file, 'sys' # For testing
    end
  end
end

desc "Run the example program"
task :example => [:build] do
  if CONFIG['host_os'] =~ /mswin|windows|mingw|cygwin|dos/i
    sh 'ruby -Ilib examples/uname_test.rb'
  else
    sh 'ruby -Iext examples/uname_test.rb'
  end
end

namespace 'sys' do
  desc "Install the sys-uname library (system)"
  task :install do
    if CONFIG['host_os'] =~ /mswin|windows|mingw|cygwin|dos/i
      dir = File.join(CONFIG['sitelibdir'], 'sys')
      Dir.mkdir(dir) unless File.exists?(dir)
      FileUtils.cp('lib/sys/uname.rb', dir, :verbose => true)
    else
      Dir.chdir('ext') do
        sh 'make install'
      end
    end
  end
end

namespace 'gem' do
  desc "Build the sys-uname gem"
  task :build do
    spec = eval(IO.read('sys-uname.gemspec'))
    if CONFIG['host_os'] =~ /windows|dos|mswin|mingw|cygwin/i
      spec.files = spec.files.reject{ |f| f.include?('ext') }
      spec.platform = Gem::Platform::CURRENT
    else
      spec.files = spec.files.reject{ |f| f.include?('lib') }
      spec.extensions = ['ext/extconf.rb']
      spec.extra_rdoc_files += ['ext/sys/uname.c']
    end
    Gem::Builder.new(spec).build
  end

  desc "Install the sys-uname gem"
  task :install => [:build] do
    file = Dir['sys-uname*.gem'].first
    sh "gem install #{file}"
  end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
  if CONFIG['host_os'] =~ /mswin|windows|mingw|cygwin|dos/i
    t.libs << 'lib'
  else
    task :test => :build
    t.libs << 'ext'
    t.libs.delete('lib')
  end
end
