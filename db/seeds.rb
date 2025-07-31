# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
EventCategory.create!([
  { name: "Trip", emoji: "🌍", description: "Outdoor adventures, getaways, and travel plans." },
  { name: "Party", emoji: "🎉", description: "Celebrations, birthdays, and festive meetups." },
  { name: "Workout", emoji: "💪", description: "Fitness sessions, runs, hikes, or classes." },
  { name: "Game Night", emoji: "🎲", description: "Board games, video games, or casual fun with friends." },
  { name: "Dinner", emoji: "🍽️", description: "Restaurant meetups or home dinners." },
  { name: "Concert", emoji: "🎵", description: "Live shows, music festivals, and performances." },
  { name: "Work/Study", emoji: "💻", description: "Co-working, study sessions, or professional meetups." },
  { name: "Movie", emoji: "🎬", description: "Cinema outings or movie nights at home." },
  { name: "Other", emoji: "📅", description: "General events." },
  { name: "Sports", emoji: "⚽", description: "Watching or playing sports, matches, or tournaments." },
])
