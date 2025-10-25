class ApoliceVO
  attr_reader :numero, :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg, :status

  def initialize(numero:, data_emissao:, inicio_vigencia:, fim_vigencia:, importancia_segurada:, lmg:, status:)
    raise ArgumentError, "numero é obrigatório" if numero.nil?
    raise ArgumentError, "data_emissao é obrigatória" if data_emissao.nil?
    raise ArgumentError, "inicio_vigencia é obrigatória" if inicio_vigencia.nil?
    raise ArgumentError, "fim_vigencia é obrigatória" if fim_vigencia.nil?
    raise ArgumentError, "importancia_segurada é obrigatória" if importancia_segurada.nil?
    raise ArgumentError, "lmg é obrigatório" if lmg.nil?

    @numero = numero
    @data_emissao = data_emissao
    @inicio_vigencia = inicio_vigencia
    @fim_vigencia = fim_vigencia
    @importancia_segurada = importancia_segurada
    @lmg = lmg
    @status = status
  end

  validate :vigencias_validas
  validate :inicio_max_30_dias
  validate :is_positivo
  validate :lmg_positivo

  private

  def vigencias_validas
    if @fim_vigencia < @inicio_vigencia
      raise ArgumentError, "fim_vigencia não pode ser anterior a inicio_vigencia"
    end
  end

  def inicio_max_30_dias
    if (@inicio_vigencia - @data_emissao).abs > 30
      raise ArgumentError, "O inicio da vigência pode ser no passado ou no futuro da data de emissão em no maximo 30 dias."
    end
  end

  def is_positivo
    if @importancia_segurada <= 0
      raise ArgumentError, "importancia_segurada deve ser um valor positivo"
    end
  end

  def lmg_positivo
    if @lmg <= 0
      raise ArgumentError, "lmg deve ser um valor positivo"
    end
  end

end
