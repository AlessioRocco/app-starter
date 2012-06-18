# Mongoid template
# Lunch this with --skip-bundle -T -O

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

run 'bundle install'

generate "mongoid:config"
generate "rspec:install"
generate "cucumber:install"

empty_directory "spec/support"
empty_directory "spec/factories"
remove_file "spec/spec_helper.rb"
create_file "spec/spec_helper.rb" do
  <<RUBY
require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    config.infer_base_class_for_anonymous_controllers = false

    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run :focus => true
    config.run_all_when_everything_filtered = true
  end

end

Spork.each_run do
  FactoryGirl.reload
end
RUBY
end

create_file "spec/support/database_cleaner.rb" do
  <<RUBY
RSpec.configure do |config|
  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
RUBY
end

create_file "spec/support/factory_girl.rb" do
  <<RUBY
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
RUBY
end

create_file "spec/support/mongoid.rb" do
  <<RUBY
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
RUBY
end

remove_file "features/env.rb"
create_file "features/env.rb" do
    <<RUBY
require 'rubygems'
require 'spork'
 
Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../../config/environment", __FILE__)
  require 'cucumber/rails'

  Capybara.default_selector = :css
  
  Before { Mongoid.master.collections.select {|c| c.name !~ /system/ }.each(&:drop) }
  World FactoryGirl::Syntax::Methods
end
 
Spork.each_run do  
  FactoryGirl.reload
end
  RUBY
end