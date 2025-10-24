class CreateTbEndossos < ActiveRecord::Migration[7.1]
  def change
    create_table :tb_endossos, id: false do |t|
      t.primary_key :numero
      t.integer :tb_apolice_numero, null: false
      t.string :tipo_endosso, null: false
      t.date :data_emissao, null: false
      t.integer :cancelado_endosso_numero
      t.date :fim_vigencia, null: false
      t.decimal :importancia_segurada, precision: 15, scale: 2, null: false

      t.timestamps
    end

    # Relação com apólice (foreign key)
    add_foreign_key :tb_endossos, :tb_apolices, column: :tb_apolice_numero, primary_key: :numero

    # Relação com outro endosso (auto-referência, para cancelamento)
    add_foreign_key :tb_endossos, :tb_endossos, column: :cancelado_endosso_numero, primary_key: :numero
  end
end
