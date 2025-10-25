class Dto::ApoliceDto
  attr_accessor :numero, :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg, :status

  def initialize(numero:, data_emissao:, inicio_vigencia:, fim_vigencia:, importancia_segurada:, lmg:, status: nil)
    raise ArgumentError, "numero é obrigatório" if numero.nil?
    raise ArgumentError, "data_emissao é obrigatório" if data_emissao.nil?
    raise ArgumentError, "inicio_vigencia é obrigatório" if inicio_vigencia.nil?
    raise ArgumentError, "fim_vigencia é obrigatório" if fim_vigencia.nil?
    raise ArgumentError, "importancia_segurada é obrigatório" if importancia_segurada.nil?
    raise ArgumentError, "lmg é obrigatório" if lmg.nil?

    @numero = numero
    @data_emissao = data_emissao
    @inicio_vigencia = inicio_vigencia
    @fim_vigencia = fim_vigencia
    @importancia_segurada = importancia_segurada
    @lmg = lmg
    @status = status
  end

end