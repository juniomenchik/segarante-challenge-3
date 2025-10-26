# app/utils/null_cleaner.rb
module NullCleaner
  module_function

  # Remove chaves com valor nil e normaliza estruturas.
  # - Se for ActiveRecord / objeto com as_json: converte primeiro.
  # - Arrays e Hashes são tratados recursivamente.
  # - Decimals são formatados com duas casas.
  def self.remove_nulls(obj)
    case obj
    when Hash
      obj.each_with_object({}) do |(k, v), h|
        cleaned = remove_nulls(v)
        h[k] = cleaned unless cleaned.nil?
      end
    when Array
      obj.map { |v| remove_nulls(v) }.reject(&:nil?)
    else
      # Se for modelo ActiveRecord ou responde a as_json, descer para hash
      if obj.respond_to?(:as_json) && !primitive?(obj)
        remove_nulls(obj.as_json)
      else
        format_leaf(obj)
      end
    end
  end

  def self.primitive?(obj)
    obj.is_a?(String) || obj.is_a?(Numeric) || obj.is_a?(TrueClass) || obj.is_a?(FalseClass) || obj.nil?
  end

  def self.format_leaf(value)
    return nil if value.nil?

    # Preserva inteiros (IDs) sem formatação de casas decimais
    if value.is_a?(Integer)
      return value
    end

    # Formata apenas BigDecimal para string com duas casas decimais
    if value.is_a?(BigDecimal)
      return sprintf('%.2f', value)
    end

    # Formata apenas Float para string com duas casas decimais
    if value.is_a?(Float)
      return sprintf('%.2f', value)
    end

    # Outros Numeric (ex: Rational) retorna como está
    if value.is_a?(Numeric)
      return value
    end

    value
  end
end