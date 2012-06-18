# Mongoid template
# Lunch this with -T -O

gem_group :test, :development do
  gem 'rspec-rails'  
  gem 'faker'
end

gem_group :test do
  gem 'cucumber-rails', require: false
  gem 'capybara'
  gem 'mongoid-rspec'
  gem 'factory_girl_rails'
  gem 'simplecov', require: false
  gem 'growl'
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-spork'
  gem 'spork-rails'
end

gem "mongoid", "~> 3.0.0.rc"
gem 'haml-rails'
gem 'thin'