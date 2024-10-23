class Rollup < ApplicationRecord
  include Threadable

  has_many :events, -> { chronologically }, dependent: :delete_all
end
