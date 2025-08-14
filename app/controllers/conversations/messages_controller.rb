class Conversations::MessagesController < ApplicationController
  before_action :set_conversation

  rate_limit to: 5, within: 30.seconds, by: -> { Current.user.cache_key }, only: :create

  def index
    @messages = paginated_messages(@conversation.messages)
  end

  def create
    @conversation.ask(question, **message_params)
  end

  private
    def set_conversation
      @conversation = Current.user.conversation
    end

    def paginated_messages(messages)
      if params[:before]
        messages.page_before(messages.find(params[:before]))
      else
        messages.last_page
      end
    end

    def question
      message_params[:content]
    end

    def message_params
      params.require(:conversation_message).permit(:content, :client_message_id)
    end
end
