module Bubble::Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events

    after_create -> { track_event :created }
  end

  private
    def track_event(action, creator: Current.user, rollup: latest_rollup, **particulars)
      transaction do
        Event.create! action: action, creator: creator, particulars: { creator_name: creator.name }.merge(particulars), rollup: rollup
        thread_entries.create! threadable: rollup
      end
    rescue ActiveRecord::RecordNotUnique
      # rollup has already been threaded
    end
end
