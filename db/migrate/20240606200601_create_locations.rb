class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :ip_address
      t.string :city
      t.string :country
      t.string :timezone


      t.timestamps
    end
  end
end
