class Endosso < ApplicationRecord
  self.table_name = "tb_endossos"
  self.primary_key = "numero"

  belongs_to :apolice, class_name: "Apolice", foreign_key: "tb_apolice_numero"
  belongs_to :cancelado_endosso, class_name: "Endosso", foreign_key: "cancelado_endosso_numero", optional: true

  scope :nao_cancelamentos, -> { where.not(tipo_endosso: "cancelamento") }
  scope :cancelamentos, -> { where(tipo_endosso: "cancelamento") }

  validates :data_emissao, :tipo_endosso, :fim_vigencia, :importancia_segurada, presence: true
  before_validation :set_data_emissao_hoje, if: -> { data_emissao.nil? }
  validate :fim_nao_antes_inicio_original
  validate :nao_negativo

  def cancelado?
    Endosso.where(cancelado_endosso_numero: numero).exists?
  end

  private

  def fim_nao_antes_inicio_original
    return if fim_vigencia.nil?
    if fim_vigencia < apolice.inicio_vigencia
      errors.add(:fim_vigencia, "fim antes do início da apólice")
    end
  end

  def nao_negativo
    errors.add(:importancia_segurada, "negativa") if importancia_segurada.to_d < 0
  end
end
