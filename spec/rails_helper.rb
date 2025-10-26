# `spec/rails_helper.rb`
RSpec.configure do |config|
  config.use_transactional_fixtures = false

  require 'database_cleaner/active_record'

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.append_after(:each) do
    DatabaseCleaner.clean
  end

  # Se precisar de truncation em testes especiais (ex: :js)
  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each, js: true) do
    DatabaseCleaner.strategy = :transaction
  end
end
