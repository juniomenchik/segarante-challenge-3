class ApolicesController < ApplicationController
  before_action :set_apolice, only: [:show, :endossos_index, :endossos_create, :endossos_show]


  def create
    apolice = Apolice.new(apolice_params.merge(status: "ATIVA", lmg: apolice_params[:importancia_segurada]))

    if apolice.save
      render json: apolice, status: :created
    else
      if apolice.errors.added?(:numero, :taken)
        render json: { erro: "numero de policie ja existe." }, status: :conflict
      else
        render json: { erro: apolice.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { erro: "numero de policie ja existe." }, status: :conflict
  end


  def index
    render json: Apolice.all
  end

  def show
    render json: {
      apolice: @apolice.as_json,
      endossos: @apolice.endossos.order(:data_emissao, :numero).as_json
    }
  end

  # Endossos
  def endossos_index
    render json: @apolice.endossos.order(:data_emissao, :numero)
  end

  def endossos_create
    endosso = EndossoCreator.new(apolice: @apolice, params: endosso_params).call
    render json: endosso, status: :created
  end

  def endossos_show
    endosso = @apolice.endossos.find(params[:endosso_id])
    render json: endosso
  end

  private

  def set_apolice
    @apolice = Apolice.find_by(numero: params[:id])
    render json: { erro: "Nao foi encontrada" }, status: :not_found unless @apolice
  end

  def apolice_params
    params.require(:apolice).permit(:numero, :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg)
  end

  def endosso_params
    params.require(:endosso).permit(:importancia_segurada, :fim_vigencia, :data_emissao)
  end
end
