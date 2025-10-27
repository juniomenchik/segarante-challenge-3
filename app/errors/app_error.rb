# ruby
# `app/errors/app_error.rb`
class AppError < StandardError
  attr_reader :http_status,
              :error_code,
              :message

  def initialize(message = "Erro interno",
                 http_status: :internal_server_error,
                 error_code: "internal_error")
    super(message)
    @http_status = http_status
    @error_code = error_code
    @message = message
  end

  def as_json(*)
    { error: { code: error_code, message: message } }
  end

end
