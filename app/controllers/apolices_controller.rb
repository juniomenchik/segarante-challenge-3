class ApolicesController < ApplicationController
  before_action :set_apolice, only: [:show, :endossos_index, :endossos_create, :endossos_show]


  def create
    apolice = Apolice.new(apolice_params.merge(status: "ATIVA", lmg: apolice_params[:importancia_segurada]))

    if apolice.save
      render json: apolice, status: :created
    else
      if apolice.errors.added?(:numero, :taken)
        render json: { erros: { numero: "numero de policie ja existe." } }, status: :conflict
      else
        render json: { erros: apolice.errors.to_hash }, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordNotUnique
    render json: { erros: { numero: "numero de policie ja existe." } }, status: :conflict
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
    if endosso_params[:tipo_endosso] == "cancelamento"
      cancelamento = EndossoCancellationService.new(apolice: @apolice).call
      render json: cancelamento, status: :created
    else
      endosso = EndossoCreator.new(apolice: @apolice, params: endosso_params).call
      render json: endosso, status: :created
    end
  rescue ActiveRecord::RecordInvalid => e
    render json: { erros: e.record.errors.to_hash }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { erros: { base: e.message } }, status: :unprocessable_entity
  end

  def endossos_show
    endosso = Endosso.find_by(numero: params[:endosso_id])
    if endosso
      render json: endosso
    else
      render json: { erro: "Endosso não encontrado" }, status: :not_found
    end
  end

  private

  def set_apolice
    @apolice = Apolice.find_by(numero: params[:id])
    @endosso  = Endosso.find_by(numero: params[:endosso_id])

    render json: { erro: "Nao foi encontrada" }, status: :not_found unless @apolice || @endosso
  end

  def apolice_params
    params.require(:apolice).permit(:numero, :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg)
  end

  def endosso_params
    params.require(:endosso).permit(:importancia_segurada, :fim_vigencia, :data_emissao, :tipo_endosso)
  end
end
