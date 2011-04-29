# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slogger/version"

Gem::Specification.new do |s|
  s.name        = "slogger"
  s.version     = Slogger::Version::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Leandro Silva"]
  s.email       = ["leandrodoze@gmail.com"]
  s.homepage    = "http://github.com/leandrosilva/slogger"
  s.summary     = %Q{Slogger is a Ruby library to help work with standard Ruby Syslog library.}
  s.description = %Q{Slogger is a Ruby library to help work with standard Ruby Syslog library. Yeah! Just it.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "rspec", "~> 2.6.0.rc2"
end
