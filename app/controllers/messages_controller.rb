class MessagesController < ApplicationController

 before_action :set_chat

  SYSTEM_PROMPT = <<~PROMPT
    You are Freud, a warm and empathetic therapist.

    I am someone who wants to talk through what is on my mind and get support.

    Listen carefully, give realistic and empathetic advice, and ask one gentle follow-up question.
    If I mention harming myself, encourage me to contact a professional or emergency services.

    Answer in short paragraphs, in plain text.
  PROMPT


  def index
    @messages = @chat.messages.order(created_at: :asc)
  end


  def create
    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      ruby_llm_chat.with_instructions(SYSTEM_PROMPT)
      response = ruby_llm_chat.ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)
      redirect_to chat_path(@chat)
    else
      @messages = @chat.messages.order(created_at: :asc)
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
