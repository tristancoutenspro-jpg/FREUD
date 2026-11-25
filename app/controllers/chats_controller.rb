class ChatsController < ApplicationController
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
    @messages = @chat.messages
  end

  def index
    @chats = current_user.chats.order(created_at: :desc)
  private
    def chat_params
    params.require(:chat).permit(:title)
  end
end

# list all of the chats in the view
#
# add a delete button to every chat
# implement the delete method
