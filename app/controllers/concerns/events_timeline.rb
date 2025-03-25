module EventsTimeline
  extend ActiveSupport::Concern

  include BucketFilterable

  included do
    before_action :set_activity_day
  end

  private
    def set_activity_day
      @activity_day = if params[:day].present?
        Time.zone.parse(params[:day])
      else
        Time.zone.now
      end
    rescue ArgumentError
      raise ActionController::RoutingError
    end

    def events_for_activity_day
      user_events.where(created_at: @activity_day.all_day).
        group_by { |event| [ event.created_at.hour, helpers.event_column(event) ] }.
        map { |hour_col, events|
          [ hour_col,
            events.uniq { |e| e.action == "boosted" ? [ e.creator_id, e.bubble_id ] : e.id }
          ]
        }
    end

    def latest_event_before_activity_day
      user_events.where(created_at: ...@activity_day.beginning_of_day).chronologically.last
    end

    def user_events
      Event.where(bubble: user_bubbles, creator: Current.account.users)
    end

    def user_bubbles
      Current.user.accessible_bubbles
            .published_or_drafted_by(Current.user)
            .where(bucket_id: bucket_filter)
    end
end
