class Chat < ApplicationRecord
  has_many :messages
  belongs_to :user

  # missed thing in scope
end
