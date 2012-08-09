# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.version       = '0.0.2'

  gem.authors       = ["Cainã Costa"]
  gem.email         = ["cainan.costa@gmail.com"]
  gem.description   = %q{Makes your MiniTest mocks more resilient.}
  gem.summary       = %q{Makes your MiniTest mocks more resilient.}
  gem.homepage      = "https://github.com/sryche/minitest-firemock"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- test/*`.split("\n")
  gem.name          = "minitest-firemock"
  gem.require_paths = ["lib"]
end
