# app/models/vo/apolice_vo.rb
require "json"

module Vo
  class ApoliceVo
    attr_reader :numero, :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg, :status

    def initialize(numero:, data_emissao:, inicio_vigencia:, fim_vigencia:, importancia_segurada:, lmg:, status:)
      errors = []

      errors << { campo: "numero", motivo: "numero é obrigatório" } if numero.nil?
      errors << { campo: "data_emissao", motivo: "data_emissao é obrigatória" } if data_emissao.nil?
      errors << { campo: "inicio_vigencia", motivo: "inicio_vigencia é obrigatória" } if inicio_vigencia.nil?
      errors << { campo: "fim_vigencia", motivo: "fim_vigencia é obrigatória" } if fim_vigencia.nil?
      errors << { campo: "importancia_segurada", motivo: "importancia_segurada é obrigatória" } if importancia_segurada.nil?
      errors << { campo: "lmg", motivo: "lmg é obrigatório" } if lmg.nil?

      # Só continua validações se valores presentes
      if fim_vigencia && inicio_vigencia && fim_vigencia < inicio_vigencia
        errors << { campo: "fim_vigencia", motivo: "fim_vigencia não pode ser anterior a inicio_vigencia" }
      end

      if inicio_vigencia && data_emissao
        diff_dias = (Date.parse(inicio_vigencia.to_s) - Date.parse(data_emissao.to_s)).to_i.abs
        if diff_dias > 30
          errors << { campo: "inicio_vigencia", motivo: "O inicio da vigência pode ser no passado ou no futuro da data de emissão em no maximo 30 dias." }
        end
      end

      if importancia_segurada
        errors << { campo: "importancia_segurada", motivo: "importancia_segurada deve ser um valor positivo" } if importancia_segurada <= 0
        importancia_segurada_str = importancia_segurada.is_a?(String) ? importancia_segurada : format("%.2f", importancia_segurada)
        unless importancia_segurada_str.match?(/\A\d+\.\d{2}\z/)
          errors << { campo: "importancia_segurada", motivo: "importancia_segurada deve ter duas casas decimais" }
        end
      end

      if lmg
        errors << { campo: "lmg", motivo: "lmg deve ser um valor positivo" } if lmg <= 0
        lmg_str = lmg.is_a?(String) ? lmg : format("%.2f", lmg)
        unless lmg_str.match?(/\A\d+\.\d{2}\z/)
          errors << { campo: "lmg", motivo: "lmg deve ter duas casas decimais" }
        end
      end

      raise ArgumentError, { errors: errors }.to_json if errors.any?

      @numero = numero
      @data_emissao = data_emissao
      @inicio_vigencia = inicio_vigencia
      @fim_vigencia = fim_vigencia
      @importancia_segurada = importancia_segurada
      @lmg = lmg
      @status = status
    end
  end
end