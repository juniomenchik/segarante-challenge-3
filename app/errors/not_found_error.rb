# ruby
# `app/errors/not_found_error.rb`
class NotFoundError < AppError
  def initialize(message = "Recurso não encontrado")
    super(message, http_status: :not_found, error_code: "not_found")
  end
end
