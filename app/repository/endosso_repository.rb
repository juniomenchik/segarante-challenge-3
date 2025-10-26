class EndossoRepository
  def initialize

  end

  def create(attrs)
    ActiveRecord::Base.transaction do
      apolice = Apolice.find(attrs.tb_apolice_numero)

      raise StandardError, "A apólice não está ativa. Não é possível criar endossos." unless apolice[:status] == "ATIVA"

      
      case attrs.tipo_endosso
      when "cancelamento"
        create_cancelamento(apolice, attrs)
      else
        create_normal(apolice, attrs)
      end
      
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
  

  def create_normal(apolice, attrs)
    endosso_criado = Endosso.create!(
      numero: attrs.numero,
      apolice: apolice,
      tipo_endosso: attrs.tipo_endosso,
      data_emissao: attrs.data_emissao,
      fim_vigencia: attrs.fim_vigencia,
      importancia_segurada: attrs.importancia_segurada,
      created_at: attrs.created_at,
      )

    apolice.update!(
      fim_vigencia: attrs.fim_vigencia || apolice.fim_vigencia,
      lmg: apolice.lmg + attrs.importancia_segurada.to_d
    )

    endosso_criado


  end

  def create_cancelamento(apolice, attrs)

    endosso_a_cancelar = apolice.endossos
                                .where.not(tipo_endosso: "cancelamento")
                                .where.not(numero: apolice.endossos
                                                          .where(tipo_endosso: "cancelamento")
                                                          .select(:cancelado_endosso_numero))
                                .order(created_at: :desc)
                                .first || apolice.endossos.where(tipo_endosso: "BASE").order(created_at: :desc).first

    cancelamento = Endosso.create!(
      numero: attrs.numero,
      apolice: apolice,
      tipo_endosso: attrs.tipo_endosso,
      data_emissao: attrs.data_emissao || Date.current,
      cancelado_endosso_numero: endosso_a_cancelar.numero
    )

    if endosso_a_cancelar.fim_vigencia != nil
      previous_endosso = find_previous_endosso_que_possua_fv(apolice, endosso_a_cancelar)
      apolice.update!(fim_vigencia: previous_endosso.fim_vigencia)
    end

    if endosso_a_cancelar.importancia_segurada != nil
      apolice.update!(lmg: apolice.lmg - endosso_a_cancelar.importancia_segurada)
    end

    if apolice.lmg <= 0 || apolice.fim_vigencia <= Date.current
      apolice.update!(
        lmg: 0,
        status: "BAIXADA"
      )
    end

    cancelamento
  end

  def find_previous_endosso_que_possua_fv(apolice, endosso_atual)
    apolice.endossos
           .where.not(tipo_endosso: "cancelamento")
           .where.not(fim_vigencia: nil)
           .where("created_at < ?", endosso_atual.created_at)
           .order(created_at: :desc)
           .first ||
      apolice.endossos.where(tipo_endosso: "BASE").where.not(fim_vigencia: nil).order(created_at: :asc).first
  end

end
