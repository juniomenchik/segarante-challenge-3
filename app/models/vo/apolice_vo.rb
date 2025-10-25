module Vo
  class ApoliceVO
    attr_accessor :numero,
                  :data_emissao,
                  :inicio_vigencia,
                  :fim_vigencia,
                  :importancia_segurada,
                  :lmg,
                  :status

    def aplicar_regras_de_negocio
      #
    end

    def initialize(numero:,
                   data_emissao:,
                   inicio_vigencia:,
                   fim_vigencia:,
                   importancia_segurada:,
                   lmg:,
                   status: nil
    )
      @numero = numero
      @data_emissao = data_emissao
      @inicio_vigencia = inicio_vigencia
      @fim_vigencia = fim_vigencia
      @importancia_segurada = importancia_segurada
      @lmg = lmg
      @status = status

      aplicar_regras_de_negocio

    end

    def self.from_dto(dto)
      new(
        numero: dto.numero,
        data_emissao: dto.data_emissao,
        inicio_vigencia: dto.inicio_vigencia,
        fim_vigencia: dto.fim_vigencia,
        importancia_segurada: dto.importancia_segurada,
        lmg: dto.lmg,
        status: dto.status
      )
    end

    def to_h
      {
        numero: @numero,
        data_emissao: @data_emissao,
        inicio_vigencia: @inicio_vigencia,
        fim_vigencia: @fim_vigencia,
        importancia_segurada: @importancia_segurada,
        lmg: @lmg,
        status: @status
      }
    end
  end
end
