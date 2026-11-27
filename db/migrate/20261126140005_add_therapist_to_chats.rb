class AddTherapistToChats < ActiveRecord::Migration[8.1]
  def change
    add_reference :chats, :therapist, foreign_key: true
  end
end
