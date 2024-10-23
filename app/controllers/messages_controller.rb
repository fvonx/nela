class MessagesController < ApplicationController

  before_action :set_conversation
  before_action :set_message, only: %i[reply destroy]

  def create
    @reply = @conversation.messages.new(message_params)

    if @reply.save
      redirect_to conversation_url(@conversation)
    else
      render :reply, status: :unprocessable_entity
    end
  end

  def reply
    @reply = @conversation.messages.new

    @reply.receivers = reply_to(@message)
    @reply.title     = @message.title
    @reply.body      = @message.body
  end

  def destroy
    @message.destroy
  
    redirect_to conversation_url(@conversation)
  end

  private

  def set_conversation
    @conversation = current_user.conversations.find(params[:conversation_id])
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:body, :title, :receivers_input, :status)
  end

end
