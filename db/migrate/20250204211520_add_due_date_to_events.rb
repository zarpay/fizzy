class AddDueDateToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :due_date, :date
  end
end
