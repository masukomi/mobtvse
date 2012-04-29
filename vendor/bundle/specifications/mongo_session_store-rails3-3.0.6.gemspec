# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "mongo_session_store-rails3"
  s.version = "3.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Hempel", "Nicolas M\u{c3}\u{a9}rouze", "Tony Pitale", "Chris Brickley"]
  s.date = "2012-04-03"
  s.email = ["plasticchicken@gmail.com"]
  s.homepage = "http://github.com/brianhempel/mongo_session_store"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Rails session stores for MongoMapper, Mongoid, or any other ODM. Rails 3.0, 3.1, and 3.2 compatible."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, [">= 0"])
      s.add_runtime_dependency(%q<actionpack>, [">= 3.0"])
    else
      s.add_dependency(%q<mongo>, [">= 0"])
      s.add_dependency(%q<actionpack>, [">= 3.0"])
    end
  else
    s.add_dependency(%q<mongo>, [">= 0"])
    s.add_dependency(%q<actionpack>, [">= 3.0"])
  end
end
