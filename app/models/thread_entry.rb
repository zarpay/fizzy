class ThreadEntry < ApplicationRecord
  belongs_to :bubble, touch: true

  delegated_type :threadable, types: %w[ Comment Rollup ], dependent: :destroy, inverse_of: :thread_entry

  scope :chronologically, -> { order created_at: :asc, id: :desc }
end
