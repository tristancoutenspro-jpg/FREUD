class ChatsController < ApplicationController
  def index
    @chats = current_user.chats.order(created_at: :desc)

    return unless params[:query].present?

    @chats = @chats.where("title ILIKE ?", "%#{params[:query]}%")
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

  def destroy
    @chat = current_user.chats.find(params[:id])
    @chat.destroy
    redirect_to chats_path, notice: "Chat deleted", status: :see_other
  end

  private

  def chat_params
    params.require(:chat).permit(:title, :therapist_id)
  end
end
