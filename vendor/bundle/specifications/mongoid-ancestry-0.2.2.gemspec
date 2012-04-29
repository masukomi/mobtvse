# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mongoid-ancestry"
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Stefan Kroes", "Anton Orel"]
  s.date = "2011-04-25"
  s.description = "Organise Mongoid model into a tree structure"
  s.email = ["eagle.anton@gmail.com"]
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/skyeagle/mongoid-ancestry"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "mongoid-ancestry"
  s.rubygems_version = "1.8.15"
  s.summary = "Ancestry allows the records of a Mongoid model to be organised in a tree structure, using a single, intuitively formatted database field. It exposes all the standard tree structure relations (ancestors, parent, root, children, siblings, descendants) and all of them can be fetched in a single query. Additional features are named_scopes, integrity checking, integrity restoration, arrangement of (sub)tree into hashes and different strategies for dealing with orphaned records."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongoid>, ["~> 2.0"])
      s.add_runtime_dependency(%q<bson_ext>, ["~> 1.3"])
    else
      s.add_dependency(%q<mongoid>, ["~> 2.0"])
      s.add_dependency(%q<bson_ext>, ["~> 1.3"])
    end
  else
    s.add_dependency(%q<mongoid>, ["~> 2.0"])
    s.add_dependency(%q<bson_ext>, ["~> 1.3"])
  end
end
