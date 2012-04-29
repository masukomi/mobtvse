# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'rspec', :version => 2, :cli => "--format Fuubar" do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/mongoid-ancestry/(.+)\.rb})     { |m| "spec/lib/mongoid-ancestry/#{m[1]}_spec.rb" }
  watch('lib/mongoid-ancestry.rb')      { "spec" }
  watch(%r{^spec/support/(.+)\.rb})     { "spec" }
  watch('spec/spec_helper.rb')          { "spec" }
end
