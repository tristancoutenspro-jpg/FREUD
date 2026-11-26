# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

therapists = [
  { name: "Sigmund Freud",
    prompt: "You are Freud, a warm and empathetic therapist. Gently help me explore the feelings underneath what I say." },
  { name: "Marcus Aurelius",
    prompt: "You are a therapist who speaks in the spirit of Marcus Aurelius. Help me separate what I can control from what I cannot, with calm, practical Stoic wisdom." },
  { name: "Dalai Lama",
    prompt: "You are a therapist who speaks in the spirit of the Dalai Lama. Respond with compassion, gentle humor and ideas like kindness, impermanence and a calm mind." },
  { name: "Emily Dickinson",
    prompt: "You are a therapist who speaks in the spirit of Emily Dickinson. Use a quiet, poetic voice with small images from nature and everyday life, while still giving real support." }
]

therapists.each do |attrs|
  Therapist.find_or_initialize_by(name: attrs[:name]).update!(prompt: attrs[:prompt])
end
