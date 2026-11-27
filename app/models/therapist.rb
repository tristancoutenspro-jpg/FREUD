class Therapist < ApplicationRecord
  has_many :chats, dependent: :restrict_with_error

  validates :name, :prompt, presence: true

  SKY_TIMES = %w[night dawn day dusk].freeze
  DEFAULT_GREETING = "Take a seat. Whenever you are ready, tell me what is on your mind.".freeze

  BASE_PROMPT = <<~PROMPT
    I am someone who wants to talk through what is on my mind and get support.

    Listen carefully, give realistic and empathetic advice, and ask one gentle follow-up question.
    If I mention harming myself, encourage me to contact a professional or emergency services.
    Never invent quotes from real people.

    Answer in short paragraphs, in plain text.
  PROMPT

  def system_prompt
    <<~PROMPT
      Your name in this conversation is #{name}. If I ask who you are or what your name is, answer as #{name}.
      You are an AI character inspired by #{name}. If I sincerely ask whether you are a real person, say honestly that you are an AI.
      You already welcomed me at the start of this session, so do not greet me again.

      #{prompt}

      #{BASE_PROMPT}
    PROMPT
  end

  # the line shown (and saved as the first message) when a chat starts
  def opening_line
    greeting.presence || DEFAULT_GREETING
  end

  # "Sigmund Freud" -> "sigmund_freud" (used for the image file names)
  def slug
    name.parameterize(separator: "_")
  end

  def sheet_path
    "therapists/#{slug}_sheet.png"
  end

  def room_path
    "scene/room_#{slug}.png"
  end

  def table_path
    "scene/table_#{slug}.png"
  end

  def sky_path(time)
    "scene/sky_#{slug}_#{time}.png"
  end
end
