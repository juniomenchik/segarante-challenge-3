module Vo
  class EndossoVO
    attr_accessor :numero,
                  :tb_apolice_numero,
                  :tipo_endosso,
                  :data_emissao,
                  :cancelado_endosso_numero,
                  :fim_vigencia,
                  :importancia_segurada

    def initialize(
      numero:,
      data_emissao:,
      tb_apolice_numero:,
      tipo_endosso: nil,
      cancelado_endosso_numero: nil,
      fim_vigencia: nil,
      importancia_segurada: nil
    )
      @numero = numero
      @tb_apolice_numero = tb_apolice_numero
      @tipo_endosso = tipo_endosso
      @data_emissao = data_emissao
      @cancelado_endosso_numero = cancelado_endosso_numero
      @fim_vigencia = fim_vigencia
      @importancia_segurada = importancia_segurada

    end

    def self.from_dto(dto)
      new(
        numero: dto.numero,
        tb_apolice_numero: dto.tb_apolice_numero,
        tipo_endosso: dto.tipo_endosso,
        data_emissao: dto.data_emissao,
        cancelado_endosso_numero: dto.cancelado_endosso_numero,
        fim_vigencia: dto.fim_vigencia,
        importancia_segurada: dto.importancia_segurada
      )
    end
  end
end
