class CreateTbApolices < ActiveRecord::Migration[7.1]
  def change
    create_table :tb_apolices, id: false do |t|
      t.primary_key :numero
      t.date :data_emissao, null: false
      t.date :inicio_vigencia, null: false
      t.date :fim_vigencia, null: false
      t.decimal :importancia_segurada, precision: 15, scale: 2, null: false
      t.decimal :lmg, precision: 15, scale: 2, null: false
      t.string :status
    end
  end
end
