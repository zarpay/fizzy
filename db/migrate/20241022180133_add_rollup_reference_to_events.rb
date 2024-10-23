class AddRollupReferenceToEvents < ActiveRecord::Migration[8.0]
  def up
    # FIXME: add null: false in another migration after data migrations happen
    add_reference :events, :rollup, foreign_key: true
    remove_column :events, :bubble_id
    remove_index :events, :action
  end

  def down
    add_reference :events, :bubble, foreign_key: true
    remove_reference :events, :rollup
    add_index :events, %i[ bubble_id action ]
  end
end
