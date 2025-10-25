class EndossoVO
  attr_reader :numero, :tb_apolice_numero, :tipo_endosso, :data_emissao, :cancelado_endosso_numero, :fim_vigencia, :importancia_segurada, :created_at

  def initialize(
    numero:,
    tb_apolice_numero:,
    tipo_endosso:,
    data_emissao:,
    cancelado_endosso_numero: nil,
    fim_vigencia: nil,
    importancia_segurada: nil,
    created_at:
  )
    raise ArgumentError, "numero é obrigatório" if numero.nil?
    raise ArgumentError, "data_emissao é obrigatória" if data_emissao.nil?
    raise ArgumentError, "created_at é obrigatório" if created_at.nil?

    @numero = numero
    @tb_apolice_numero = tb_apolice_numero
    @tipo_endosso = tipo_endosso
    @data_emissao = data_emissao
    @cancelado_endosso_numero = cancelado_endosso_numero
    @fim_vigencia = fim_vigencia
    @importancia_segurada = importancia_segurada
    @created_at = created_at
  end

  validate :lmg_positivo

  private

  def lmg_positivo
    if @lmg <= 0
      raise ArgumentError, "lmg deve ser um valor positivo"
    end
  end

end

