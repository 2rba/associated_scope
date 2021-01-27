# frozen_string_literal: true

require 'bundler/setup'
require 'associated_scope'
require "active_record"
require 'factory_bot'
require "pry-byebug"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
# ActiveRecord::Base.logger = Logger.new(STDOUT)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.include FactoryBot::Syntax::Methods

  config.before(:each) do
    ActiveRecord::Base.connection.begin_transaction(joinable: false)
  end

  config.after(:each) do
    ActiveRecord::Base.connection.rollback_transaction
  end
end
