class CreateOffers < ActiveRecord::Migration[7.2]
  def change
    create_table :offers do |t|
      t.string :kind, null: false
      t.jsonb :meta, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.belongs_to :product, foreign_key: true, null: true

      t.timestamps
    end

    add_index :offers, :kind
    add_index :offers, :active
  end
end
