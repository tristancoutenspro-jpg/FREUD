class PagesController < ApplicationController
  def home
    @chats = current_user.chats
    @therapists = Therapist.all

  end
end
