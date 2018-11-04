require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'sys-uname'
  spec.version    = '1.0.4'
  spec.author     = 'Daniel J. Berger'
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://github.com/djberg96/sys-uname'
  spec.summary    = 'An interface for returning uname (platform) information'
  spec.license    = 'Artistic-2.0'
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') } 
  spec.test_files = Dir['test/test*.rb']
  spec.cert_chain = ['certs/djberg96_pub.pem']

  spec.extra_rdoc_files  = ['CHANGES', 'README', 'MANIFEST', 'doc/uname.txt']

  spec.add_dependency('ffi', '>= 1.0.0')

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/djberg96/sys-uname',
    'bug_tracker_uri'   => 'https://github.com/djberg96/sys-uname/issues',
    'changelog_uri'     => 'https://github.com/djberg96/sys-uname/blob/ffi/CHANGES',
    'documentation_uri' => 'https://github.com/djberg96/sys-uname/wiki',
    'source_code_uri'   => 'https://github.com/djberg96/sys-uname',
    'wiki_uri'          => 'https://github.com/djberg96/sys-uname/wiki'
  }

  spec.description = <<-EOF
    The sys-uname library provides an interface for gathering information
    about your current platform. The library is named after the Unix 'uname'
    command but also works on MS Windows. Available information includes
    OS name, OS version, system name and so on. Additional information is
    available for certain platforms.
  EOF
end
