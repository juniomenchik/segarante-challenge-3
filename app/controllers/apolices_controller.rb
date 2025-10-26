class ApolicesController < ApplicationController

  before_action :initialize_classes

  def initialize_classes
    @apolice_service = ApoliceService.new
    @endosso_service = EndossoService.new
  end

  def create
    begin
      entity = @apolice_service.criar_apolice(apolice_params)
      render json: entity, status: :created

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def index
    begin
      entities = @apolice_service.listar_apolices
      render json: entities, status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def show
    begin
      entity = @apolice_service.consulta_por_numero_da_apolicie(params[:id])
      render json: entity, status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  def endossos_create
    begin
      entity = @endosso_service.criar_endosso(params[:id],endosso_params)
      render json: entity, status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end
  end

  # Endossos
  def endossos_index
    begin

      entity = @endosso_service.consultar_endossos_de_uma_apolicie_pelo_numero(params[:id])
      render json: entity, status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end

  end


  def endossos_show

    begin
      entity = @endosso_service.consultar_endosso_de_apolice(params[:id], params[:endosso_id])
      render json: entity, status: :ok

    rescue StandardError => e
      render json: e.message, status: :unprocessable_entity
    end

  end

  private

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
      :importancia_segurada,
      :tb_apolice_numero,
      :fim_vigencia,
      :data_emissao,
      :tipo_endosso
    )
  end
end
