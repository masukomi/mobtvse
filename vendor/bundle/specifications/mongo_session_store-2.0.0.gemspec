# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mongo_session_store"
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nicolas M\u{c3}\u{a9}rouze", "Tony Pitale", "Chris Brickley"]
  s.date = "2010-10-12"
  s.email = "nicolas.merouze@gmail.com"
  s.extra_rdoc_files = ["README.md"]
  s.files = ["README.md"]
  s.homepage = "http://github.com/nmerouze/mongo_session_store"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Rails session store class implemented for MongoMapper and Mongoid"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_development_dependency(%q<mongo_mapper-rails3>, [">= 0.7.2"])
      s.add_development_dependency(%q<mongoid>, ["~> 2.0"])
    else
      s.add_dependency(%q<actionpack>, ["~> 3.0"])
      s.add_dependency(%q<mongo_mapper-rails3>, [">= 0.7.2"])
      s.add_dependency(%q<mongoid>, ["~> 2.0"])
    end
  else
    s.add_dependency(%q<actionpack>, ["~> 3.0"])
    s.add_dependency(%q<mongo_mapper-rails3>, [">= 0.7.2"])
    s.add_dependency(%q<mongoid>, ["~> 2.0"])
  end
end
