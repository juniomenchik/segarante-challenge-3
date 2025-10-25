class ApoliceRepository
  def initialize
  end

  def create(attrs)
    Apolice.create!(attrs)
  end

  def find_all
    Apolice.all
  end

  def find_by_numero_and_endossos(numero)
    apolice = Apolice.find_by(numero: numero)
    return nil unless apolice

    {
      apolice: apolice.as_json,
      endossos: apolice.endossos.order(:data_emissao).as_json
    }
  end

  def update_apolice(apolice, attrs)
    apolice.update!(attrs)
    apolice
  end

end
