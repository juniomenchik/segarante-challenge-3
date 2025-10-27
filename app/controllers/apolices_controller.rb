class ApolicesController < ActionController::API

  before_action :initialize_classes

  rescue_from StandardError, with: :render_error

  def initialize_classes
    @apolice_service = ApoliceService.new
    @endosso_service = EndossoService.new
  end

  def create
    entity = @apolice_service.criar_apolice(apolice_params)
    render json: NullCleaner.remove_nulls(entity), status: :created
  end

  def index
    entities = @apolice_service.listar_apolices
    render json: NullCleaner.remove_nulls(entities), status: :ok
  end

  def show
    entity = @apolice_service.consulta_por_numero_da_apolicie(params[:id])
    render json: NullCleaner.remove_nulls(entity), status: :ok
  end

  def endossos_create
    entity = @endosso_service.criar_endosso(params[:id],endosso_params)
    render json: NullCleaner.remove_nulls(entity), status: :created
  end


  def endossos_index
    entity = @endosso_service.consultar_endossos_de_uma_apolicie_pelo_numero(params[:id])
    render json: NullCleaner.remove_nulls(entity), status: :ok
  end

  def endossos_show
    entity = @endosso_service.consultar_endosso_de_apolice(params[:id], params[:endosso_id])
    render json: NullCleaner.remove_nulls(entity), status: :ok
  end

  def apolice_params
    params.require(:apolice).permit(
      :numero,
      :data_emissao,
      :inicio_vigencia,
      :fim_vigencia,
      :importancia_segurada,
      :lmg
    )
  end

  def endosso_params
    params.require(:endosso).permit(
      :id,
      :numero,
      :importancia_segurada,
      :tb_apolice_numero,
      :fim_vigencia,
      :data_emissao,
      :tipo_endosso
    )
  end

  private

  def render_error(error)
    app_error = error.is_a?(AppError) ? error : AppError.new(error.message)
    render json: {
      error: {
        code: app_error.error_code || "internal_error",
        message: app_error.message
      }
    }, status: app_error.http_status || :internal_server_error
  end

end
