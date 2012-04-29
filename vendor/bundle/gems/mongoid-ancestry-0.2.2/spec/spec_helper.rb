require 'rubygems'
require 'bundler/setup'

require 'mongoid'
require 'rspec'

require 'mongoid-ancestry'

Mongoid.configure do |config|
  logger = Logger.new('log/test.log')
  config.master = Mongo::Connection.new('localhost', 27017,
    :logger => logger).db('ancestry_test')
  config.logger = logger
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.after :each do
    Mongoid.master.collections.reject { |c| c.name =~ /^system\./ }.each(&:drop)
  end
end
