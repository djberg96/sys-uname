require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

WINDOWS = CONFIG['host_os'] =~ /msdos|mswin|win32|windows|mingw|cygwin/i

CLEAN.include(
  '**/*.gem',               # Gem files
  '**/*.rbc',               # Rubinius
  '**/*.o',                 # C object file
  '**/*.log',               # Ruby extension build log
  '**/Makefile',            # C Makefile
  '**/conftest.dSYM',       # OS X build directory
  "**/*.#{CONFIG['DLEXT']}" # C shared object
)

desc "Run the example program"
task :example => [:build] do
  if WINDOWS
    sh 'ruby -Ilib examples/uname_test.rb'
  else
    sh 'ruby -Iext examples/uname_test.rb'
  end
end

namespace 'gem' do
  desc "Create the sys-uname gem"
  task :create do
    spec = eval(IO.read('sys-uname.gemspec'))
    if WINDOWS
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
  task :install => [:create] do
    file = Dir['sys-uname*.gem'].first
    sh "gem install #{file}"
  end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
  if WINDOWS
    t.libs << 'lib'
  else
    task :test => :build
    t.libs << 'ext'
    t.libs.delete('lib')
  end
end

task :default => :test
