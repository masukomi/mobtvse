# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "unidecode"
  s.version = "1.0.0"

  s.required_rubygems_version = nil if s.respond_to? :required_rubygems_version=
  s.authors = ["Russell Norris"]
  s.autorequire = "unicode"
  s.cert_chain = nil
  s.date = "2007-09-05"
  s.email = "rsl@luckysneaks.com"
  s.extra_rdoc_files = ["README"]
  s.files = ["README"]
  s.homepage = "http://unidecode.rubyforge.org/"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--main", "README", "--charset", "utf-8"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new("> 0.0.0")
  s.rubygems_version = "1.8.15"
  s.summary = "A library for converting (transliterating) UTF-8 strings to plain ASCII representations"

  if s.respond_to? :specification_version then
    s.specification_version = 1

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
