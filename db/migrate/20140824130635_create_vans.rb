class CreateVans < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    create_table :vans do |t|
      t.string :make
      t.string :model
      t.hstore :tags

      t.timestamps
    end
  end
end
