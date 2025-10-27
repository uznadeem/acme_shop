class CreateDeliveryRules < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_rules do |t|
      t.integer :threshold_cents, null: false
      t.integer :fee_cents,       null: false
      t.timestamps
    end

    add_index :delivery_rules, :threshold_cents, unique: true
  end
end
