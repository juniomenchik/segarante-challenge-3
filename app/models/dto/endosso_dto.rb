class Dto::EndossoDTO

  attr_accessor :numero, :tb_apolice_numero, :tipo_endosso, :data_emissao, :cancelado_endosso_numero, :fim_vigencia, :importancia_segurada

  def initialize(
    numero:,
    tb_apolice_numero:,
    tipo_endosso:,
    data_emissao:,
    cancelado_endosso_numero:,
    fim_vigencia:,
    importancia_segurada:
  )

    raise ArgumentError, "numero é obrigatório" if numero.nil?
    raise ArgumentError, "tb_apolice_numero é obrigatório" if tb_apolice_numero.nil?
    raise ArgumentError, "data_emissao é obrigatório" if data_emissao.nil?

    @numero = numero
    @tb_apolice_numero = tb_apolice_numero
    @tipo_endosso = tipo_endosso
    @data_emissao = data_emissao
    @cancelado_endosso_numero = cancelado_endosso_numero
    @fim_vigencia = fim_vigencia
    @importancia_segurada = importancia_segurada
  end

end
