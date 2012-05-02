# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "timecop"
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Trupiano"]
  s.date = "2010-06-07"
  s.description = "A gem providing \"time travel\" and \"time freezing\" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call."
  s.email = "jtrupiano@gmail.com"
  s.extra_rdoc_files = ["LICENSE", "README.rdoc"]
  s.files = ["LICENSE", "README.rdoc"]
  s.homepage = "http://github.com/jtrupiano/timecop"
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "johntrupiano"
  s.rubygems_version = "1.8.15"
  s.summary = "A gem providing \"time travel\" and \"time freezing\" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
