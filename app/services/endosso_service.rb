class EndossoService

  def initialize
    @endosso_repo = EndossoRepository.new
  end

    def criar_endosso(tb_apolice_numero, endosso_dto)

    endosso_vo = Vo::EndossoVo.new(
      numero: endosso_dto[:numero] || nil,
      tb_apolice_numero: tb_apolice_numero,
      tipo_endosso: endosso_dto[:tipo_endosso] || nil,
      data_emissao: endosso_dto[:data_emissao] || Date.today,
      fim_vigencia: endosso_dto[:fim_vigencia] || nil,
      importancia_segurada: endosso_dto[:importancia_segurada] || nil,
    )

    @endosso_repo.create(endosso_vo)

  end

  def listar_endossos
  end

  def consultar_endosso_de_apolice( numero_apolice, numero_endosso)

    @endosso_repo.find_by_police_endosso(numero_apolice, numero_endosso)

  end

  def consultar_endossos_de_uma_apolicie_pelo_numero(numero_apolice)

    @endosso_repo.find_by_apolice_numero(numero_apolice)

  end

end
