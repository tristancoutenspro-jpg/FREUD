class ChatsController < ApplicationController
  def index
    @chats = current_user.chats.order(created_at: :desc)
  end

  def create
    @chat = Chat.new(chat_params)
    @chat.title = "New chat" if @chat.title.blank?
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

  private

  def chat_params
    params.require(:chat).permit(:title)
  end
end
