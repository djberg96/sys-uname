require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'sys-uname'
  spec.version   = '0.8.4'
  spec.license   = 'Artistic 2.0'
  spec.author    = 'Daniel J. Berger'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://www.rubyforge.org/projects/sysutils'
  spec.platform  = Gem::Platform::RUBY
  spec.summary   = 'An interface for returning system platform information'
  spec.test_file = 'test/test_sys_uname.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/uname.txt']
  spec.rubyforge_project = 'sysutils'

  spec.add_development_dependency('test-unit', '>= 2.0.6')
   
  spec.description = <<-EOF
    The sys-uname library provides an interface for gathering information
    about your current platform. The library is named after the Unix 'uname'
    command but also works on MS Windows. Available information includes
    OS name, OS version, system name and so on. Additional information is
    available for certain platforms.
  EOF
end
