# `app/models/vo/endosso_vo.rb`
module Vo
  class EndossoVo
    require "json"

    TIPOS = {
      aumento_is: "aumento_is",
      reducao_is: "reducao_is",
      aumento_is_alteracao_vigencia: "aumento_is_alteracao_vigencia",
      reducao_is_alteracao_vigencia: "reducao_is_alteracao_vigencia",
      alteracao_vigencia: "alteracao_vigencia",
      cancelamento: "cancelamento",
      base: "BASE"
    }.freeze

    attr_reader :numero,
                :tb_apolice_numero,
                :tipo_endosso,
                :data_emissao,
                :cancelado_endosso_numero,
                :fim_vigencia,
                :importancia_segurada,
                :lmg,
                :created_at

    def initialize(
      numero:,
      tb_apolice_numero:,
      tipo_endosso:,
      data_emissao:,
      fim_vigencia: nil,
      importancia_segurada: nil
    )
      errors = []

      errors << { campo: "data_emissao", motivo: "data_emissao é obrigatória" } if data_emissao.nil?

      if importancia_segurada
        # Aceita positivo ou negativo; valida formato com duas casas decimais
        importancia_segurada_str = importancia_segurada.is_a?(String) ? importancia_segurada : format("%.2f", importancia_segurada.to_f)
        unless importancia_segurada_str.match?(/\A-?\d+\.\d{2}\z/)
          errors << { campo: "importancia_segurada", motivo: "importancia_segurada deve ter duas casas decimais (pode ser negativa para redução)" }
        end
      end

      if lmg
        lmg_str = lmg.is_a?(String) ? lmg : format("%.2f", lmg.to_f)
        unless lmg_str.match?(/\A\d+\.\d{2}\z/)
          errors << { campo: "lmg", motivo: "lmg deve ter duas casas decimais" }
        end
        errors << { campo: "lmg", motivo: "lmg deve ser um valor positivo" } if lmg.to_f <= 0
      end

      raise ArgumentError, { errors: errors }.to_json if errors.any?

      tipo = determinar_tipo_endosso(
        fim_vigencia,importancia_segurada
      )

      @numero = numero
      @tb_apolice_numero = tb_apolice_numero
      @data_emissao = data_emissao
      @fim_vigencia = fim_vigencia
      @importancia_segurada = importancia_segurada
      @lmg = lmg
      @created_at = Time.now
      @tipo_endosso = tipo_endosso || tipo
    end

    private

    def determinar_tipo_endosso(fim_vigencia,importancia_segurada)

      valor = importancia_segurada.to_f

      if fim_vigencia
        if importancia_segurada

          return TIPOS[:aumento_is_alteracao_vigencia] if valor > 0
          return TIPOS[:reducao_is_alteracao_vigencia] if valor < 0
        end
        return TIPOS[:alteracao_vigencia]
      else
        return TIPOS[:aumento_is] if valor > 0
        return TIPOS[:reducao_is] if valor < 0
      end

      TIPOS[:base]
    end
  end
end
