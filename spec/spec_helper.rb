# spec/rails_helper.rb (mínimo funcional)
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort('Ambiente de produção!') if Rails.env.production?
require 'rspec/rails'

# Carrega suporte (se existir)
Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

# Mantém schema atualizado
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end