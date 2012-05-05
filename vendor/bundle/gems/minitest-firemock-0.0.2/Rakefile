begin
  require 'bundler/gem_tasks'
rescue LoadError
  warn "No bundler found, you won't be able to build the gem."
end

require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << ['lib', 'test']
  t.test_files = FileList['test/*/*_test.rb']
  t.verbose = true
  t.warning = true
end

task default: :test
