class CreateBaskets < ActiveRecord::Migration[7.2]
  def change
    create_table :baskets do |t|
      t.timestamps
    end
  end
end
