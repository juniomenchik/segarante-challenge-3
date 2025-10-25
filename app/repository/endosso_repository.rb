class EndossoRepository
  def initialize
  end

  def create(attrs)
    Endosso.transaction do
    Endosso.create!(attrs)
    end
  end

  def find_all
    Endosso.transaction do
    Endosso.all
    end
  end

  def find_by_numero(numero)
    Endosso.transaction do
    Endosso.find_by(numero: numero)
    end
  end

  def update_endosso(endosso, attrs)
    Endosso.transaction do
    endosso.update!(attrs)
    endosso
    end
  end

end
