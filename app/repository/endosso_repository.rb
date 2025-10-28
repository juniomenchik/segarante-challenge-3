class EndossoRepository
  def initialize

  end

  def create(tb_apolice_numero,endosso_dto)
    ActiveRecord::Base.transaction do
      apolice = Apolice.find(tb_apolice_numero)

      raise StandardError, "A apólice não está ativa. Não é possível criar endossos." unless apolice[:status] == "ATIVA"

      if endosso_dto[:tipo_endosso] != nil
        if endosso_dto[:tipo_endosso] == "cancelamento"
          return create_cancelamento(apolice,endosso_dto)
        end
      end

      create_normal(apolice,endosso_dto)

    end
  end

  def find_all
    ActiveRecord::Base.transaction do
      Endosso.all
    end
  end

  def find_by_police_endosso(numero_apolice, numero_endosso)
    ActiveRecord::Base.transaction do

      apolice = Apolice.find_by(numero: numero_apolice)
      raise NotFoundError.new("Apólice de numero: #{numero_apolice} não encontrada") unless apolice

      endosso = apolice.endossos.find_by(numero: numero_endosso)
      raise NotFoundError.new("Endosso de numero: #{numero_endosso} não encontrado") unless endosso

      endosso
    end

  end

  def find_by_apolice_numero(numero)
    ActiveRecord::Base.transaction do
      endosso = Endosso.where.not(tb_apolice_numero: nil).where(tb_apolice_numero: numero)

      raise NotFoundError.new("Não existem endossos para a apólice de número: #{numero}") if endosso.empty?

      endosso
    end
  end
  

  def create_normal(apolice, attrs)

    # CRIAR ENDOSSO VALIDO
    endosso_valido = Vo::EndossoVo.new(
      apolice: apolice,
      numero: attrs[:numero] || nil,
      tb_apolice_numero: apolice.numero,
      tipo_endosso: attrs[:tipo_endosso] || nil,
      data_emissao: attrs[:data_emissao] || Date.today,
      fim_vigencia: attrs[:fim_vigencia] || nil,
      importancia_segurada: attrs[:importancia_segurada] || nil,
      observacao: attrs[:observacao] || nil
    )

    # CRIAR ENDOSSO NO BANCO
    endosso_criado = Endosso.create!(
      numero: endosso_valido.numero || nil,
      apolice: apolice,
      tipo_endosso: endosso_valido.tipo_endosso,
      data_emissao: endosso_valido.data_emissao,
      fim_vigencia: endosso_valido.fim_vigencia || nil,
      importancia_segurada: endosso_valido.importancia_segurada || nil,
      created_at: endosso_valido.created_at || DateTime.current,
      observacao: endosso_valido.observacao || nil
      )

    # APLICAR ENDOSSO  NA APOLICE.
    apolice_valida = Vo::ApoliceVo.atualizando_apolice(
      numero: apolice.numero,
      data_emissao: apolice.data_emissao,
      inicio_vigencia: apolice.inicio_vigencia,
      fim_vigencia: endosso_valido.fim_vigencia || apolice.fim_vigencia,
      importancia_segurada: apolice.importancia_segurada,
      lmg: apolice.lmg + (endosso_valido.importancia_segurada || 0),
      status: apolice.status,
      observacao: endosso_valido.observacao || apolice.observacao
    )

    apolice.update!(
      fim_vigencia: apolice_valida.fim_vigencia,
      lmg: apolice_valida.lmg,
      observacao: apolice_valida.observacao,
      status: apolice_valida.status
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
      numero: attrs[:numero],
      apolice: apolice,
      tipo_endosso: attrs[:tipo_endosso],
      data_emissao: attrs[:data_emissao] || Date.current,
      cancelado_endosso_numero: endosso_a_cancelar.numero
    )

    if endosso_a_cancelar.fim_vigencia != nil
      previous_endosso = find_previous_endosso_que_possua_fv(apolice, endosso_a_cancelar)
      apolice.update!(fim_vigencia: previous_endosso.fim_vigencia)
    end

    if endosso_a_cancelar.observacao != nil
      previous_endosso = find_previous_endosso_que_possua_observacao(apolice, endosso_a_cancelar)
      apolice.update!(observacao: previous_endosso.observacao)
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

  def find_previous_endosso_que_possua_observacao(apolice, endosso_atual)
    apolice.endossos
           .where.not(tipo_endosso: "cancelamento")
           .where.not(observacao: nil)
           .where("created_at < ?", endosso_atual.created_at)
           .order(created_at: :desc)
           .first ||
      apolice.endossos.where(tipo_endosso: "BASE").where.not(fim_vigencia: nil).order(created_at: :asc).first

  end

end
