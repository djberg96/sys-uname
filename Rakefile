require 'rake'
require 'rake/testtask'
require 'rbconfig'
include Config

desc "Run the example program"
task :example do
  if CONFIG['host_os'] =~ /mswin|windows/i
    sh 'ruby -Ilib/windows examples/uname_test.rb'
  else
    sh 'ruby -Ilib/unix examples/uname_test.rb'
  end
end

namespace :gem do
  desc "Build the gem"
  task :build do
    spec = eval(IO.read('sys-uname.gemspec'))
    Gem::Builder.new(spec).build
  end

  task :install => [:build] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
  if CONFIG['host_os'] =~ /mswin|windows|dos|cygwin|mingw/i
    t.libs << 'lib/windows'
  else
    t.libs << 'lib/unix'
  end

  t.warning = true
  t.verbose = true
end
