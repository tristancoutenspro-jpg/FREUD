class SuggestChatsTool < RubyLLM::Tool
  description "Searches chats by keyword in title."
  parameter :query, description: "The keyword to search for"

  def execute(query:)
    chats = Chat.all
    query.split.each do |word|
      chats = chats.where("title ILIKE :q", q: "%#{word}%")
    end

    chats.map do |chat|
      { title: chat.title, url: "/chats/#{chat.id}" }
    end
  end
end
