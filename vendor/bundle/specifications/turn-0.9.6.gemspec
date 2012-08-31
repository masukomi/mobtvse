# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "turn"
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Thomas Sawyer", "Tim Pease"]
  s.date = "2012-06-28"
  s.description = "Turn provides a set of alternative runners for MiniTest, both colorful and informative."
  s.email = ["transfire@gmail.com", "tim.pease@gmail.com"]
  s.executables = ["turn"]
  s.extra_rdoc_files = ["History.txt", "Version.txt", "LICENSE-GPL2.txt", "LICENSE-RUBY.txt", "LICENSE-MIT.txt", "Release.txt", "LICENSE.txt", "README.md"]
  s.files = ["bin/turn", "History.txt", "Version.txt", "LICENSE-GPL2.txt", "LICENSE-RUBY.txt", "LICENSE-MIT.txt", "Release.txt", "LICENSE.txt", "README.md"]
  s.homepage = "http://rubygems.org/gems/turn"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Test Reporters (New) -- new output formats for Testing"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ansi>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<ansi>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<ansi>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
