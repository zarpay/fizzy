module Bubble::Commentable
  extend ActiveSupport::Concern

  included do
    has_many :comments

    scope :ordered_by_comments, -> { left_joins(:comments).group(:id).order("COUNT(comments.id) DESC") }
  end

  def comment!(body)
    transaction do
      comment = comments.create! body: body
      thread_entries.create! threadable: comment
    end
  end
end
