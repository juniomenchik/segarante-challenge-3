class Endosso < ApplicationRecord
  self.table_name = "tb_endossos"
  self.primary_key = "numero"

  belongs_to :apolice, class_name: "Apolice", foreign_key: "tb_apolice_numero"
  belongs_to :cancelado_endosso, class_name: "Endosso", foreign_key: "cancelado_endosso_numero", optional: true

  scope :nao_cancelamentos, -> { where.not(tipo_endosso: "cancelamento") }
  scope :nao_bases, -> { where.not(tipo_endosso: "BASE") }
  scope :cancelamentos, -> { where(tipo_endosso: "cancelamento") }

  validates :data_emissao, :tipo_endosso, presence: true
  before_validation :set_data_emissao_hoje, if: -> { data_emissao.nil? }

  def cancelado?
    Endosso.where(cancelado_endosso_numero: numero).exists?
  end

end

