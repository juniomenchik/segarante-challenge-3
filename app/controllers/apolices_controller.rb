class ApolicesController < ActionController::API

  before_action :initialize_classes

  rescue_from AppError, with: :render_app_error
  rescue_from StandardError, with: :render_internal_error

  def initialize_classes
    @apolice_service = ApoliceService.new
    @endosso_service = EndossoService.new
  end

  def create
    begin
      entity = @apolice_service.criar_apolice(apolice_params)
      render json: NullCleaner.remove_nulls(entity), status: :created

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def index
    begin
      entities = @apolice_service.listar_apolices
      render json: NullCleaner.remove_nulls(entities), status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def show
    entity = @apolice_service.consulta_por_numero_da_apolicie(params[:id])
    render json: NullCleaner.remove_nulls(entity), status: :ok
  end

  def endossos_create
    begin
      entity = @endosso_service.criar_endosso(params[:id],endosso_params)
      render json: NullCleaner.remove_nulls(entity), status: :created

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  # Endossos
  def endossos_index
    begin

      entity = @endosso_service.consultar_endossos_de_uma_apolicie_pelo_numero(params[:id])
      render json: NullCleaner.remove_nulls(entity), status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end

  end

  def endossos_show

    begin
      entity = @endosso_service.consultar_endosso_de_apolice(params[:id], params[:endosso_id])
      render json: NullCleaner.remove_nulls(entity), status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end

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

  def render_app_error(error)
    render json: error.as_json, status: error.http_status
  end

  def render_internal_error(error)
    render json: { error: { code: "internal_error", message: error.message } }, status: :internal_server_error
  end

end
