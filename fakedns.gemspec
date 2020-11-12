lib = File.expand_path('../lib/', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

require 'fakedns'
Gem::Specification.new do |s|
	
	# Information
	s.name = FakeDNS::APP_NAME
	s.version = FakeDNS::VERSION
	s.date = '2014-01-11'
	s.summary = 'A Fake DNS server'
	s.description = 'A fake dns server to use with dynamic malware analysis'
	s.required_ruby_version = '>= 2.1'
	s.author = FakeDNS::AUTHOR
	
	# Files
	s.require_path = 'bin'
	s.files = Dir['lib/**/*'] + Dir['bin/*']
	#s.files = Dir.glob('bin/')
	s.executables << 'fakedns'
	
end
