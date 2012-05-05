# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "minitest-firemock"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Caina\u{303} Costa"]
  s.date = "2011-10-10"
  s.description = "Makes your MiniTest mocks more resilient."
  s.email = ["cainan.costa@gmail.com"]
  s.homepage = "https://github.com/sryche/minitest-firemock"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.15"
  s.summary = "Makes your MiniTest mocks more resilient."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
