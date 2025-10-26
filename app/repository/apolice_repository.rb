class ApoliceRepository
  def initialize
  end

  def create(attrs)
    ActiveRecord::Base.transaction do
      apolice = Apolice.create!({
                        numero: attrs.numero,
                        data_emissao: attrs.data_emissao,
                        inicio_vigencia: attrs.inicio_vigencia,
                        fim_vigencia: attrs.fim_vigencia,
                        importancia_segurada: attrs.importancia_segurada,
                        lmg: attrs.lmg,
                        status: attrs.status
                      })

      Endosso.create!(
        numero: rand(100000..999999).to_s,
        apolice: apolice,
        tipo_endosso: "BASE",
        fim_vigencia: attrs.fim_vigencia,
        data_emissao: attrs.data_emissao,
        importancia_segurada: attrs.importancia_segurada,
        created_at: Time.current
      )

      apolice
    end
  end

  def find_all
    ActiveRecord::Base.transaction do
      Apolice.all
    end
  end

  def consulta_por_numero_da_apolicie(numero)
    Apolice.transaction do
      apolice = Apolice.find_by(numero: numero)
      return nil unless apolice

      {
        apolice: apolice.as_json,
        endossos: apolice.endossos.order(:data_emissao).as_json
      }
    end
  end

  def update_apolice(apolice, attrs)
    Apolice.transaction do
      apolice.update!(attrs)
      apolice
    end
  end

end
