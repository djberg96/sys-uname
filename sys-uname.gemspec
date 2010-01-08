require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name      = 'sys-uname'
   gem.version   = '0.8.4'
   gem.author    = 'Daniel J. Berger'
   gem.email     = 'djberg96@gmail.com'
   gem.homepage  = 'http://www.rubyforge.org/projects/sysutils'
   gem.platform  = Gem::Platform::RUBY
   gem.summary   = 'An interface for returning uname (platform) information'
   gem.test_file = 'test/test_sys_uname.rb'
   gem.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/uname.txt']
   gem.rubyforge_project = 'sysutils'
   
   gem.files = Dir["doc/*"] + Dir["test/*"] + Dir["[A-Z]*"]
   gem.files.delete_if{ |item| item.include?('CVS') }

   gem.description = <<-EOF
      The sys-uname library provides an interface for gathering information
      about your current platform. The library is named after the Unix 'uname'
      command but also works on MS Windows. Available information includes
      OS name, OS version, system name and so on. Additional information is
      available for certain platforms.
   EOF
end

if $PROGRAM_NAME == __FILE__
   require 'rbconfig'
   include Config
   
   if CONFIG['host_os'] =~ /mswin|windows/i
      spec.required_ruby_version = '>= 1.8.2'
      spec.files += ['lib/sys/uname.rb']
      spec.platform = Gem::Platform::CURRENT
   else
      spec.required_ruby_version = '>= 1.8.0'
      spec.extensions = ['ext/extconf.rb']
      spec.files += ['ext/sys/uname.c']
      spec.extra_rdoc_files += ['ext/sys/uname.c']
   end
	
   Gem.manage_gems if Gem::RubyGemsVersion.to_f < 1.0
   Gem::Builder.new(spec).build
end
