class Event < ApplicationRecord
  include Assignments, Stages

  belongs_to :creator, class_name: "User"
  belongs_to :rollup, touch: true

  has_one :account, through: :creator

  store_accessor :particulars, :creator_name

  scope :chronologically, -> { order created_at: :asc, id: :desc }
end
