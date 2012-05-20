# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "bourbon"
  s.version = "2.0.0.rc1"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.authors = ["Phil LaPier", "Chad Mazzola", "Matt Jankowski", "Nick Quaranto", "Jeremy Raines", "Mike Burns", "Andres Mejia", "Travis Haynes", "Chris Lloyd", "Gabe Berke-Williams", "J. Edward Dewyea"]
  s.date = "2012-03-16"
  s.description = "The purpose of Bourbon Vanilla Sass Mixins is to provide a comprehensive framework of\nsass mixins that are designed to be as vanilla as possible. Meaning they\nshould not deter from the original CSS syntax. The mixins contain vendor\nspecific prefixes for all CSS3 properties for support amongst modern\nbrowsers. The prefixes also ensure graceful degradation for older browsers\nthat support only CSS3 prefixed properties.\n"
  s.email = ["support@thoughtbot.com"]
  s.executables = ["bourbon"]
  s.files = ["bin/bourbon"]
  s.homepage = "https://github.com/thoughtbot/bourbon"
  s.require_paths = ["lib"]
  s.rubyforge_project = "bourbon"
  s.rubygems_version = "1.8.15"
  s.summary = "Bourbon Sass Mixins using SCSS syntax."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sass>, [">= 3.1"])
      s.add_development_dependency(%q<aruba>, ["~> 0.4"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<sass>, [">= 3.1"])
      s.add_dependency(%q<aruba>, ["~> 0.4"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<sass>, [">= 3.1"])
    s.add_dependency(%q<aruba>, ["~> 0.4"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
