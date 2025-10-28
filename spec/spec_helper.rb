# spec/rails_helper.rb (mínimo funcional)
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
  puts "[spec_helper] Migrações pendentes detectadas. Executando db:migrate..."
  # Executa migrations pendentes para ambiente de teste
  # Usa verbose=false para saída limpa
  ActiveRecord::Migration.verbose = false
  # Garante que estamos no ambiente test
  if Rails.env.test?
    # Roda migrate
    require 'rake'
    Rails.application.load_tasks unless Rake::Task.task_defined?('db:migrate')
    Rake::Task['db:migrate'].invoke
    # Revalida schema
    ActiveRecord::Migration.maintain_test_schema!
    puts "[spec_helper] Migrações aplicadas com sucesso."
  else
    abort e.to_s.strip
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end