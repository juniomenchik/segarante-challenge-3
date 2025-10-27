# ruby
# `app/errors/not_found_error.rb`
class NotFoundError < AppError
  attr_reader :http_status,
              :error_code,
              :message

  def initialize(message = "Recurso não encontrado")
    super(
      message,
      http_status: :not_found,
      error_code: "404_not_found")
  end
end
