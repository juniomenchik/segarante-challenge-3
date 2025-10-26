# Ruby
class Apolice < ApplicationRecord
  validates :numero, presence: true, uniqueness: true

  self.table_name = "tb_apolices"
  self.primary_key = "numero"

  has_many :endossos, class_name: "Endosso", foreign_key: "tb_apolice_numero", inverse_of: :apolice

end
