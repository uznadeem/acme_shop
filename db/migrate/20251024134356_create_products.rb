class CreateProducts < ActiveRecord::Migration[7.2]
  def change
    create_table :products do |t|
      t.string  :code, null: false
      t.string  :name, null: false
      t.integer :price_cents, null: false

      t.timestamps
    end
    add_index :products, :code, unique: true
  end
end
