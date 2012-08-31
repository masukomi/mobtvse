# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "libwebsocket/version"

Gem::Specification.new do |s|
  s.name        = "libwebsocket"
  s.version     = LibWebSocket::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bernard Potocki"]
  s.email       = ["bernard.potocki@imanel.org"]
  s.homepage    = "http://github.com/imanel/libwebsocket"
  s.summary     = %q{Universal Ruby library to handle WebSocket protocol}
  s.description = %q{Universal Ruby library to handle WebSocket protocol}

  s.add_dependency 'addressable'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
