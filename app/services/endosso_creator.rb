class EndossoCreator
  TIPOS = {
    aumento_is: "aumento_is",
    reducao_is: "reducao_is",
    alteracao_vigencia: "alteracao_vigencia",
    aumento_is_alteracao_vigencia: "aumento_is_alteracao_vigencia",
    reducao_is_alteracao_vigencia: "reducao_is_alteracao_vigencia",
    cancelamento: "cancelamento"
  }.freeze

  def initialize(apolice:, params:)
    @apolice = apolice
    @nova_is = params[:importancia_segurada].to_d
    @novo_fim = params[:fim_vigencia].presence
    @data_emissao = params[:data_emissao].presence
  end

  def call

    raise "A apólice está baixada." if @apolice.status == "BAIXADA"

    ActiveRecord::Base.transaction do
      tipo = determinar_tipo
      endosso = Endosso.create!(
        apolice: @apolice,
        tipo_endosso: tipo,
        data_emissao: @data_emissao || Date.current,
        fim_vigencia: @novo_fim,
        importancia_segurada: @nova_is
      )
      @apolice.aplicar_snapshot!(
        snapshot_is: endosso.importancia_segurada,
        snapshot_fim_vigencia: endosso.fim_vigencia
      ) unless tipo == TIPOS[:cancelamento]
      endosso
    end
  end

  private

  def determinar_tipo

    fim_atual = @apolice.fim_vigencia

    if @novo_fim != nil
      mudou_fim = @novo_fim != fim_atual
      return TIPOS[:aumento_is_alteracao_vigencia] if mudou_fim && @nova_is > 0
      return TIPOS[:reducao_is_alteracao_vigencia] if mudou_fim && @nova_is < 0
      return TIPOS[:alteracao_vigencia] if mudou_fim
    end

    return TIPOS[:aumento_is] if @nova_is > 0
    return TIPOS[:reducao_is] if @nova_is < 0

    raise ActiveRecord::RecordInvalid.new(@apolice), "Nada mudou"
  end

  def aplicar_snapshot_apolice!(endosso)
    @apolice.aplicar_snapshot!(
      snapshot_is: endosso.importancia_segurada,
      snapshot_fim_vigencia: endosso.fim_vigencia
    )
  end
end
