class EndossoCancellationService
  def initialize(apolice:)
    @apolice = apolice
  end

  def call
    ActiveRecord::Base.transaction do
      alvo = ultimo_endosso_cancellable!
      cancelamento = Endosso.create!(
        apolice: @apolice,
        tipo_endosso: EndossoCreator::TIPOS[:cancelamento],
        data_emissao: Date.today,
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
                .max_by { |x| x.created_at }
    raise ActiveRecord::RecordNotFound, "Sem endosso válido para cancelar" unless e
    e
  end


  def recalcular_estado!
    ultimo_endosso = @apolice.endossos
                             .where.not(tipo_endosso: EndossoCreator::TIPOS[:cancelamento])
                             .where.not(numero: Endosso.where(tipo_endosso: EndossoCreator::TIPOS[:cancelamento])
                                                       .select(:cancelado_endosso_numero))
                             .order(created_at: :desc)
                             .first

    if ultimo_endosso
      @apolice.aplicar_snapshot!(
        snapshot_is: ultimo_endosso.importancia_segurada,
        snapshot_fim_vigencia: ultimo_endosso.fim_vigencia
      )
    else
      @apolice.update!(
        fim_vigencia: @apolice.inicio_vigencia,
        importancia_segurada: 0,
        lmg: 0,
        status: "BAIXADA"
      )
    end
  end

end