class CommentsController < ApplicationController
  include BubbleScoped, BucketScoped

  def create
    @bubble.comment! params.require(:comment).expect(:body)
    redirect_to @bubble
  end
end
