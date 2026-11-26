class MessagesController < ApplicationController
  before_action :set_chat

  def index
    @messages = @chat.messages
  end

  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      @ruby_llm_chat.with_instructions(@chat.therapist.system_prompt)
      build_conversation_history
      response = @ruby_llm_chat.ask(@message.content)

      Message.create(role: "assistant", content: response.content, chat: @chat)
      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages.order(created_at: :asc)
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def build_conversation_history
    @chat.messages.where.not(id: @message.id).order(:created_at, :id).each do |message|
      @ruby_llm_chat.add_message(role: message.role.to_sym, content: message.content)
    end
  end

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
