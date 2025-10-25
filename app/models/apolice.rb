# Ruby
class Apolice < ApplicationRecord
  validates :numero, presence: true, uniqueness: true

  self.table_name = "tb_apolices"
  self.primary_key = "numero"

  has_many :endossos, class_name: "Endosso", foreign_key: "tb_apolice_numero", inverse_of: :apolice

  validates :data_emissao, :inicio_vigencia, :fim_vigencia, :importancia_segurada, :lmg, presence: true
  validate :vigencias_validas
  validate :inicio_max_30_dias

  def lmg_positivo?(new_lmg)
    new_lmg > 0
  end

  def aplicar_snapshot!(snapshot_is:, snapshot_fim_vigencia:)

    if snapshot_fim_vigencia != nil
      update!(
        fim_vigencia: snapshot_fim_vigencia,
        status: cobertura_ativa?(snapshot_fim_vigencia) ? "ATIVA" : "BAIXADA"
      )
    end

    if snapshot_is != nil

      new_lmg = lmg + snapshot_is

      update!(
        # importancia_segurada: snapshot_is,  DEVO ATUALIZAR O IS ORIGINAL ?
        lmg: lmg_positivo?(new_lmg)    ? new_lmg : lmg,
        status: lmg_positivo?(new_lmg) ? "ATIVA" : "BAIXADA"
      )
    end

  end

  def cobertura_ativa?(fim)
    Date.today <= fim
  end

  private

  def vigencias_validas
    errors.add(:fim_vigencia, "Não deve ser anterior ao Inicio.") if fim_vigencia < inicio_vigencia
  end

  def inicio_max_30_dias
    return if (inicio_vigencia - data_emissao).abs <= 30
    errors.add(:inicio_vigencia, "O inicio da vigência pode ser no passado ou no futuro da data de emissão em no maximo 30 dias.")
  end
end
