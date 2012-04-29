# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mongoid-ancestry/version"

Gem::Specification.new do |s|
  s.name        = 'mongoid-ancestry'
  s.version     = Mongoid::Ancestry::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Stefan Kroes", "Anton Orel"]
  s.email       = ["eagle.anton@gmail.com"]
  s.description = %q{Organise Mongoid model into a tree structure}
  s.homepage    = "http://github.com/skyeagle/mongoid-ancestry"
  s.summary     = %q{Ancestry allows the records of a Mongoid model to be organised in a tree structure, using a single, intuitively formatted database field. It exposes all the standard tree structure relations (ancestors, parent, root, children, siblings, descendants) and all of them can be fetched in a single query. Additional features are named_scopes, integrity checking, integrity restoration, arrangement of (sub)tree into hashes and different strategies for dealing with orphaned records.}
  s.licenses    = ["MIT"]

  s.rubyforge_project = "mongoid-ancestry"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.extra_rdoc_files = [
    "README.md"
  ]

  s.add_dependency('mongoid', "~> 2.0")
  s.add_dependency('bson_ext', "~> 1.3")
end

