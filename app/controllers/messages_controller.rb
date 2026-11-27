class MessagesController < ApplicationController
  before_action :set_chat

  def index
    @messages = @chat.messages
  end

  def create
    @message = @chat.messages.new(message_params)
    @message.role = "user"

    return render_invalid_message unless @message.save

    @reply = ask_therapist
    return reply_failed unless @reply

    respond_to do |format|
      format.turbo_stream # renders messages/create.turbo_stream.erb (no page reload)
      format.html { redirect_to chat_path(@chat) }
    end
  end

  private

  # Asks the AI and saves its answer. Returns the saved message, or nil if anything went wrong.
  def ask_therapist
    ruby_llm_chat = RubyLLM.chat
    ruby_llm_chat.with_instructions(@chat.therapist.system_prompt)
    build_conversation_history(ruby_llm_chat)
    response = ruby_llm_chat.ask(@message.content)

    @chat.messages.create!(role: "assistant", content: response.content)
  rescue StandardError => e
    Rails.logger.error("Therapist reply failed: #{e.class}: #{e.message}")
    nil
  end

  # replays the earlier messages so the AI remembers the conversation
  def build_conversation_history(ruby_llm_chat)
    history = @chat.messages.where.not(id: @message.id).order(:created_at, :id).to_a
    # the opening greeting is already in the system prompt, and AI providers want the conversation to start with the person
    history.shift while history.first&.role == "assistant"

    history.each do |message|
      ruby_llm_chat.add_message(role: message.role.to_sym, content: message.content)
    end
  end

  # the AI failed: forget the unanswered message and give the text back so it can be re-sent
  def reply_failed
    draft = @message.content
    @message.destroy
    @message = Message.new(content: draft)

    respond_to do |format|
      format.turbo_stream { render :failed, status: :bad_gateway }
      format.html { redirect_to chat_path(@chat), alert: "I lost my train of thought. Please try again." }
    end
  end

  def render_invalid_message
    respond_to do |format|
      format.turbo_stream { head :unprocessable_entity }
      format.html do
        @messages = @chat.messages.order(created_at: :asc)
        render "chats/show", status: :unprocessable_entity
      end
    end
  end

  def set_chat
    @chat = current_user.chats.find(params[:chat_id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
