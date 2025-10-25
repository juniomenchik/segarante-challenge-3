class EndossoCancellationService
  def initialize(apolice:)
    @apolice = apolice
  end

  def call(data_emissao:)
    ActiveRecord::Base.transaction do
      alvo = ultimo_endosso_cancellable!
      cancelamento = Endosso.create!(
        apolice: @apolice,
        tipo_endosso: EndossoCreator::TIPOS[:cancelamento],
        data_emissao: data_emissao,
        fim_vigencia: alvo.fim_vigencia,
        importancia_segurada: alvo.importancia_segurada,
        cancelado_endosso_numero: alvo.numero
      )
      recalcular_estado!
      cancelamento
    end
  end

  private

  def ultimo_endosso_cancellable!
    e = @apolice.endossos
                .nao_cancelamentos
                .select { |x| !x.cancelado? }
                .max_by { |x| [x.data_emissao, x.numero] }
    raise ActiveRecord::RecordNotFound, "Sem endosso válido para cancelar" unless e
    e
  end

  def recalcular_estado!
    validos = @apolice.endossos
                      .nao_cancelamentos
                      .reject(&:cancelado?)
                      .sort_by { |x| [x.data_emissao, x.numero] }
    if validos.empty?
      # Volta para o estado original gravado na própria apólice (assumindo que já reflete último snapshot antes de qualquer endosso)
      # Se expirado, BAIXADA.
      status = Date.today <= @apolice.fim_vigencia ? "ATIVA" : "BAIXADA"
      @apolice.update!(lmg: @apolice.importancia_segurada, status: status)
    else
      ultimo = validos.last
      @apolice.aplicar_snapshot!(
        snapshot_is: ultimo.importancia_segurada,
        snapshot_fim_vigencia: ultimo.fim_vigencia
      )
    end
  end
end