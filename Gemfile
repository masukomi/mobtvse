source 'https://rubygems.org'

gem 'rails', '~> 3'

gem 'rake'

# MongoDB drivers
gem 'mongo', '~>1.5.2'
gem 'bson', '~>1.5.2'
gem 'bson_ext', '~>1.5.2'
gem "mongoid", "~> 2.3.4"
gem 'mongoid_rails_migrations'
gem "mongo_session_store-rails3"

# Rendering engines and vendor libraries
gem 'jquery-rails', '~> 2'
gem 'redcarpet'
gem "haml-rails", '~> 0.3.4'

# Misc libraries
# gem 'bcrypt-ruby', '~> 3', require: 'bcrypt'
gem 'stringex', '~> 1', :git => 'git://github.com/rsl/stringex.git'
gem 'kaminari', '~> 0.13'

#gem 'mongoid_taggable', git: 'git://github.com/ches/mongoid_taggable.git'
gem 'mongoid_taggable', :git => 'git://github.com/wilkerlucio/mongoid_taggable.git', :ref => '1cbdd5cb22ab3e75626677bac64e3b3c7ceca553'

gem 'thin', '~> 1'
group :production do
  # gem 'newrelic_rpm', '~> 3'
  # gem 'dalli', '~> 1'
  # gem 'pg', '~> 0.13'
end

group :development do
  # Extention libraries
  # gem 'heroku', '~> 2'
  # gem 'capistrano', '~> 2.9'
  # gem 'guard', '~> 1'
  # gem 'guard-rspec', '~> 0.6'
  # gem 'guard-spork', '~> 0.5'
  gem 'rails_best_practices', '~> 1'
end

group :test do
  gem 'capybara', '~> 1'
  gem 'spork', '~> 0.9'
  gem 'database_cleaner', '~> 0.7'
  gem 'minitest'
  gem 'minitest-firemock'
  gem 'timecop'
end

group :development, :test do
  gem 'foreman', '~> 0.40'
  gem 'sqlite3', '~> 1', :platform => [:ruby, :mswin, :mingw]
  gem 'faker', '~> 1'
  gem 'factory_girl_rails', '~> 1'
end

group :assets do
  gem 'sass-rails', '~> 3'
  gem 'coffee-rails', '~> 3'
  gem 'uglifier', '~> 1'
end
