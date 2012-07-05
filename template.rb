# Mongoid template
# Lunch this with --skip-bundle -T -O

gem_group :test, :development do
  gem 'rspec-rails'  
  gem 'faker'
end

gem_group :test do
  gem "turnip"  
  gem 'capybara'
  gem 'mongoid-rspec'
  gem 'factory_girl_rails'
  gem 'simplecov', require: false
  gem 'growl'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'spork-rails'
end

gem "mongoid", "~> 3.0.0.rc"
gem 'haml-rails'
gem 'thin'

run 'bundle install'

generate "mongoid:config"

append_to_file "config/mongoid.yml", <<-MD

test:
  sessions:
    default:
      database: #{@app_name}_test
      hosts:
        - localhost:27017
      options:
        consistency: :strong
MD

generate "rspec:install"

empty_directory "spec/support"
empty_directory "spec/factories"
empty_directory "spec/acceptance"
empty_directory "spec/acceptance/steps"
empty_directory "spec/routing"

append_to_file ".rspec", "-r turnip/rspec"

remove_file "spec/spec_helper.rb"
create_file "spec/spec_helper.rb", <<-MD
require 'rubygems'
require 'spork'
#uncomment the following line to use spork with the debugger
#require 'spork/ext/ruby-debug'

Spork.prefork do
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'turnip/capybara'

  Dir[Rails.root.join("spec/acceptance/steps/**/*_steps.rb"), Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

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
MD

create_file "spec/support/database_cleaner.rb", <<-MD
RSpec.configure do |config|
  # Clean/Reset Mongoid DB prior to running the tests
  config.before :each do
    Mongoid.purge!
  end
end
MD

create_file "spec/support/factory_girl.rb", <<-MD
RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
end
MD

create_file "spec/support/mongoid.rb", <<-MD
RSpec.configure do |config|
  config.include Mongoid::Matchers
end
MD

create_file "Guardfile", <<-MD
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.+\.rb$})
  watch(%r{^config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/spec_helper.rb') { :rspec }
  watch(%r{^spec/support/.+\.rb$})
end


guard 'rspec', :version => 2, :cli => '--drb' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/\#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/\#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/\#{m[1]}\#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/\#{m[1]}_routing_spec.rb", "spec/\#{m[2]}s/\#{m[1]}_\#{m[2]}_spec.rb", "spec/acceptance/\#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { |m| "spec/requests/\#{m[1]}_spec.rb" }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$})   { |m| Dir[File.join("**/\#{m[1]}.feature")][0] || 'spec/acceptance' }
end

MD