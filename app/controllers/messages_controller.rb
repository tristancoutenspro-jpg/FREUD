class MessagesController < ApplicationController
  before_action :set_chat

  def index
    @messages = @chat.messages.order(created_at: :asc)
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"
    if @message.save
    redirect_to chat_path(@chat)
    else
    render "chats/show", status: :unprocessable_entity
    end
end

  private

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
