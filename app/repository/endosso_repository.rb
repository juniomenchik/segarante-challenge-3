class EndossoRepository
  def initialize

  end

  def create(attrs)
    ActiveRecord::Base.transaction do
      apolice = Apolice.find(attrs.tb_apolice_numero)

      raise StandardError, "A apólice não está ativa. Não é possível criar endossos." unless apolice[:status] == "ATIVA"

      endosso = attrs.tipo_endosso == "cancelamento" ? create_cancelamento(apolice, attrs) : create_normal(apolice, attrs)

      apolice.aplicar_endosso(endosso)
      endosso
    end
  end

  def find_all
    ActiveRecord::Base.transaction { Endosso.all }
  end

  def find_by_police_endosso(numero_apolice, numero_endosso)
    ActiveRecord::Base.transaction do
      apolice = Apolice.find_by(numero: numero_apolice)
      raise ActiveRecord::RecordNotFound, "Apólice não encontrada" unless apolice

      endosso = apolice.endossos.find_by(numero: numero_endosso)
      raise ActiveRecord::RecordNotFound, "Endosso não encontrado para esta apólice" unless endosso

      endosso
    end

  end

  def find_by_apolice_numero(numero)
    ActiveRecord::Base.transaction do
      endosso = Endosso.where.not(tb_apolice_numero: nil).where(tb_apolice_numero: numero)
      endosso
    end
  end

  def update_endosso(endosso, attrs)
    ActiveRecord::Base.transaction do
      endosso.update!(attrs)
      endosso
    end
  end

  def create_normal(apolice, attrs)
    Endosso.create!(
      apolice: apolice,
      tipo_endosso: attrs.tipo_endosso,
      data_emissao: attrs.data_emissao,
      fim_vigencia: attrs.fim_vigencia,
      importancia_segurada: attrs.importancia_segurada,
      created_at: attrs.created_at,
      )
  end

  def create_cancelamento(apolice, attrs)
    # Endosso mais recente elegível para cancelamento (não é cancelamento e não já cancelado)
    endosso_a_cancelar = apolice.endossos
                                .where.not(tipo_endosso: "cancelamento")
                                .where.not(numero: apolice.endossos
                                                          .where(tipo_endosso: "cancelamento")
                                                          .select(:cancelado_endosso_numero))
                                .order(created_at: :desc)
                                .first

    raise ActiveRecord::RecordNotFound, "Sem endosso válido para cancelar" unless endosso_a_cancelar

    cancelamento = Endosso.create!(
      apolice: apolice,
      tipo_endosso: attrs.tipo_endosso,
      data_emissao: attrs.data_emissao || Date.current,
      cancelado_endosso_numero: endosso_a_cancelar.numero
    )

    ativos_restantes = apolice.endossos
                              .where.not(tipo_endosso: "cancelamento")
                              .where.not(numero: apolice.endossos
                                                        .where(tipo_endosso: "cancelamento")
                                                        .select(:cancelado_endosso_numero))

    if ativos_restantes.exists?
      ultimo_ativo = ativos_restantes.order(created_at: :desc).first
      total_importancia = ativos_restantes.sum(:importancia_segurada)

      apolice.update!(
        fim_vigencia: ultimo_ativo.fim_vigencia,
        importancia_segurada: total_importancia,
        lmg: total_importancia,
        status: "ATIVA"
      )
    else
      # Endosso base para recuperar fim_vigencia original (se existir)
      endosso_base = apolice.endossos.order(created_at: :asc).first
      apolice.update!(
        fim_vigencia: endosso_base&.fim_vigencia || apolice.inicio_vigencia,
        importancia_segurada: 0,
        lmg: 0,
        status: "BAIXADA"
      )
    end

    cancelamento
  end

end
