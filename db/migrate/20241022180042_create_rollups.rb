class CreateRollups < ActiveRecord::Migration[8.0]
  def change
    create_table :rollups do |t|
      t.timestamps
    end
  end
end
