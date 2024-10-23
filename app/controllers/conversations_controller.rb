class ConversationsController < ApplicationController

  before_action :set_conversation, only: %i[show]
  after_action  :mark_as_seen,     only: %i[show]

  def index
    @conversations = current_user.conversations.most_recent_first.includes(:latest_message)

    if params[:filter] == 'unseen'
      @conversations = @conversations.unseen
    end
  end

  def show
    @messages = @conversation.messages.most_recent_first
  end

  def new
    @conversation = current_user.conversations.new
    @conversation.messages.build
  end

  def create
    @conversation = current_user.conversations.new(conversation_params)
    @message      = @conversation.messages.first

    @message&.sender = current_user.address

    if @conversation.save
      redirect_to conversation_url(@conversation)
    else
      render :new, status: :unprocessable_entity 
    end
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:id])
  end

  def mark_as_seen
    @conversation.seen!
  end

  def conversation_params
    params.require(:conversation).permit(
      messages_attributes: [
        :receivers_input, 
        :title,
        :body
      ]
    )
  end
  
end