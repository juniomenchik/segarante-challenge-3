# Ruby
class Apolice < ApplicationRecord
  validates :numero, presence: true, uniqueness: true

  self.table_name = "tb_apolices"
  self.primary_key = "numero"

  has_many :endossos, class_name: "Endosso", foreign_key: "tb_apolice_numero", inverse_of: :apolice

  # enum status: { ATIVA: "ATIVA", BAIXADA: "BAIXADA" }

  validates :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg, presence: true
  validate :vigencias_validas
  validate :inicio_max_30_dias

  def aplicar_snapshot!(snapshot_is:, snapshot_fim_vigencia:)
    update!(
      importancia_segurada: snapshot_is,
      fim_vigencia: snapshot_fim_vigencia,
      lmg: snapshot_is,
      status: cobertura_ativa?(snapshot_fim_vigencia) ? "ATIVA" : "BAIXADA"
    )
  end

  def cobertura_ativa?(fim)
    Date.today <= fim
  end

  private

  def vigencias_validas
    errors.add(:fim_vigencia, "fim antes do início") if fim_vigencia < inicio_vigencia
  end

  def inicio_max_30_dias
    return if (inicio_vigencia - data_emissao).abs <= 30
    errors.add(:inicio_vigencia, "diferença maior que 30 dias da emissão")
  end
end
