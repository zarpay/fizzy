class EventSummary < ApplicationRecord
  include Messageable

  has_many :events, -> { chronologically }, dependent: :delete_all, inverse_of: :summary do
    def tallied_boosts
      boosts.group(:creator).count
    end
  end
end
