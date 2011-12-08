require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rbconfig'

CLEAN.include("**/*.rbc", "**/*.rbx", "**/*.gem")

desc "Run the example program"
task :example do
  if File::ALT_SEPARATOR
    sh 'ruby -Ilib/windows examples/uname_test.rb'
  else
    sh 'ruby -Ilib/unix examples/uname_test.rb'
  end
end

namespace :gem do
  desc "Create the sys-uname gem"
  task :create => [:clean] do
    spec = eval(IO.read('sys-uname.gemspec'))

    if File::ALT_SEPARATOR
      spec.platform = Gem::Platform::CURRENT
      spec.platform.cpu = 'universal'
      spec.platform.version = nil
    end
    
    Gem::Builder.new(spec).build
  end

  desc "Install the sys-uname gem"
  task :install => [:build] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

desc "Run the test suite"
Rake::TestTask.new("test") do |t|
  if File::ALT_SEPARATOR
    t.libs << 'lib/windows'
  else
    t.libs << 'lib/unix'
  end

  t.warning = true
  t.verbose = true
end

task :default => :test
