# ruby
# `app/errors/validation_error.rb`
class ValidationError < AppError
  def initialize(message = "Dados inválidos")
    super(message, http_status: :unprocessable_entity, error_code: "validation_error")
  end
end
