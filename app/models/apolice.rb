# Ruby
class Apolice < ApplicationRecord
  validates :numero, presence: true, uniqueness: true

  self.table_name = "tb_apolices"
  self.primary_key = "numero"

  has_many :endossos, class_name: "Endosso", foreign_key: "tb_apolice_numero", inverse_of: :apolice

  def aplicar_endosso(endosso)

    if endosso[:tipo_endosso] == "CANCELAMENTO"

    else

      if endosso[:fim_vigencia] != nil
        update!(
          fim_vigencia: endosso[:fim_vigencia],
          status: endosso[:fim_vigencia] < Date.today ? "BAIXADA" : "ATIVA"
        )
      end

      if endosso[:importancia_segurada] != nil
        new_lmg = lmg + endosso[:importancia_segurada].to_d

        update!(
          lmg: new_lmg > 0 ? new_lmg : lmg,
          status: new_lmg > 0 ? "ATIVA" : "BAIXADA"
        )
      end

    end



  end
end
