class CreateTrips < ActiveRecord::Migration[7.1]
  def change
    create_table :trips do |t|
      t.string :name, null: false, limit: 100
      t.string :image_url, null: false, limit: 100
      t.string :short_description, null: false, limit: 255
      t.text :long_description, null: false, limit: 500
      t.integer :rating, null: false

      t.timestamps
    end

    add_check_constraint :trips, 'rating >= 1 AND rating <= 5', name: 'rating_range'
    add_index :trips, :name, unique: true
    add_index :trips, :rating
  end
end
