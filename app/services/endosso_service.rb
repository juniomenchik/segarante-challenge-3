class EndossoService

  def initialize
    @endosso_repo = EndossoRepository.new
  end

  def criar_endosso(tb_apolice_numero, endosso_dto)

    @endosso_repo.create(tb_apolice_numero, endosso_dto)

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
