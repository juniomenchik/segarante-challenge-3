class ApoliceRepository
  def initialize
  end

  def create(attrs)
    Apolice.transaction do
    Apolice.create!(attrs)
    end
  end

  def find_all
    Apolice.transaction do
    Apolice.all
    end
  end

  def find_by_numero_and_endossos(numero)
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
