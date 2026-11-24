class MessagesController < ApplicationController
  def index
    @messages = Message.all
  end


  def create
    @message= Message.new(message_params)

    if @message.save
    redirect_to message_path(@message)
    else
      render :new, status: :unprocessable_entity

    end
  end
  private

    def message_params
      params.require(:message).permit(:content, :role)
    end
end
