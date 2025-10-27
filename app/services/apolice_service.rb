class ApoliceService

  def initialize
    @apolice_repo = ApoliceRepository.new
  end

  def criar_apolice(apolice_dto)

    apolice_vo = Vo::ApoliceVo.new(
      numero: apolice_dto[:numero],
      data_emissao: apolice_dto[:data_emissao],
      inicio_vigencia: apolice_dto[:inicio_vigencia],
      fim_vigencia: apolice_dto[:fim_vigencia],
      importancia_segurada: apolice_dto[:importancia_segurada],
      lmg: apolice_dto[:lmg],
      status: "ATIVA"
    )

    @apolice_repo.create(apolice_vo)

  end

  def consulta_por_numero_da_apolicie(numero_apolice)
    apolice = @apolice_repo.consulta_por_numero_da_apolicie(numero_apolice)
    raise NotFoundError.new("Apólice de numero: #{numero_apolice} não encontrada") unless apolice
    apolice
  end

  def listar_apolices
    @apolice_repo.find_all
  end

end
