class ChatsController < ApplicationController
  def create
    @chat = Chat.new(title: "New chat")
    @chat.user = current_user
    if @chat.save
      redirect_to chat_path(@chat)
    else
      redirect_to root_path, alert: "Could not start a chat"
    end
  end

  def show
    @chat = current_user.chats.find(params[:id])
    @messages = @chat.messages.order(created_at: :asc)
  end
end
