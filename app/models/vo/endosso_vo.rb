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
      base: "BASE",
      neutro: "neutro",
      invalido: "invalido"
    }.freeze

    attr_reader :numero,
                :apolice,
                :tb_apolice_numero,
                :tipo_endosso,
                :data_emissao,
                :cancelado_endosso_numero,
                :fim_vigencia,
                :importancia_segurada,
                :lmg,
                :observacao,
                :created_at

    def initialize(
      apolice:,
      numero:,
      tb_apolice_numero:,
      tipo_endosso:,
      data_emissao:,
      fim_vigencia: nil,
      importancia_segurada: nil,
      observacao:
    )
      errors = []

      errors << { campo: "apolice", motivo: "apolice é obrigatório" } if numero.nil?
      errors << { campo: "data_emissao", motivo: "data_emissao é obrigatória" } if data_emissao.nil?
      errors << { campo: "tb_apolice_numero", motivo: "tb_apolice_numero é obrigatória" } if data_emissao.nil?
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
        apolice,
        importancia_segurada,
        fim_vigencia,
        observacao
      )

      if tipo == TIPOS[:invalido]
        raise ValidationError.new("Endosso inválido: não há alterações válidas para criar o endosso")
      end

      @numero = numero
      @tb_apolice_numero = tb_apolice_numero
      @data_emissao = data_emissao
      @fim_vigencia = fim_vigencia
      @importancia_segurada = importancia_segurada
      @lmg = lmg
      @created_at = Time.now
      @tipo_endosso = tipo_endosso || tipo
      @observacao = observacao
    end

    private

    def determinar_tipo_endosso(apolice,
                                importancia_segurada,
                                fim_vigencia,
                                observacao)

      fv_atual = apolice.fim_vigencia
      ob_atual = apolice.observacao

      if importancia_segurada != nil && importancia_segurada > 0

        if fim_vigencia != nil && fim_vigencia != fv_atual
          return TIPOS[:aumento_is_alteracao_vigencia]
        end
        return TIPOS[:aumento_is]
      elsif importancia_segurada != nil && importancia_segurada < 0
        if fim_vigencia != nil && fim_vigencia != fv_atual
          return TIPOS[:reducao_is_alteracao_vigencia]
        end
        return TIPOS[:reducao_is]
      end

      if fim_vigencia != nil && fim_vigencia != fv_atual.to_s
        return TIPOS[:alteracao_vigencia]
      end

      if observacao != nil && observacao != ob_atual
        return TIPOS[:neutro]
      end

      TIPOS[:invalido]
    end
  end

end

