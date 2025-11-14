# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
[
  { key: "admin", name: "Administrator", description: "Full platform access, including managing users, content, and settings." },
  { key: "organizer", name: "Organizer", description: "Manages events and groups they own or are invited to co-manage." },
  { key: "moderator", name: "Moderator", description: "Can review and moderate community content, comments, and reports." },
  { key: "member", name: "Member", description: "Default access for signed-in users." }
].each do |role_attrs|
  Role.find_or_create_by!(key: role_attrs[:key]) do |role|
    role.name = role_attrs[:name]
    role.description = role_attrs[:description]
  end
end

[
  { name: "Trip", emoji: "🌍", description: "Outdoor adventures, getaways, and travel plans." },
  { name: "Party", emoji: "🎉", description: "Celebrations, birthdays, and festive meetups." },
  { name: "Workout", emoji: "💪", description: "Fitness sessions, runs, hikes, or classes." },
  { name: "Game Night", emoji: "🎲", description: "Board games, video games, or casual fun with friends." },
  { name: "Dinner", emoji: "🍽️", description: "Restaurant meetups or home dinners." },
  { name: "Concert", emoji: "🎵", description: "Live shows, music festivals, and performances." },
  { name: "Work/Study", emoji: "💻", description: "Co-working, study sessions, or professional meetups." },
  { name: "Movie", emoji: "🎬", description: "Cinema outings or movie nights at home." },
  { name: "Other", emoji: "📅", description: "General events." },
  { name: "Sports", emoji: "⚽", description: "Watching or playing sports, matches, or tournaments." }
].each do |category_attrs|
  EventCategory.find_or_create_by!(name: category_attrs[:name]) do |category|
    category.emoji = category_attrs[:emoji]
    category.description = category_attrs[:description]
  end
end

[
  {
    key: "basic",
    name: "Starter Circle",
    tagline: "Host a handful of intimate plans for free.",
    monthly_price_cents: 0,
    annual_price_cents: 0,
    max_active_events: 3,
    highlighted: false,
    priority: 1,
    features: [
      "Up to 3 active events",
      "Smart invites & RSVPs",
      "Shared maps & files"
    ]
  },
  {
    key: "social_plus",
    name: "Social Spark",
    tagline: "Level up recurring hangs with extra capacity.",
    monthly_price_cents: 1200,
    annual_price_cents: 12000,
    max_active_events: 10,
    highlighted: true,
    priority: 2,
    features: [
      "Up to 10 active events",
      "Priority reminders & follow-ups",
      "Group polls & suggestion boosts",
      "Guest availability heatmap"
    ]
  },
  {
    key: "galaxy",
    name: "Galaxy Host",
    tagline: "All-access hosting for power planners.",
    monthly_price_cents: 2400,
    annual_price_cents: 24000,
    max_active_events: nil,
    highlighted: false,
    priority: 3,
    features: [
      "Unlimited active events",
      "VIP launch announcements",
      "White-glove onboarding for groups",
      "Advanced analytics & share insights"
    ]
  }
].each do |plan_attrs|
  Plan.find_or_initialize_by(key: plan_attrs[:key]).tap do |plan|
    plan.assign_attributes(plan_attrs)
    plan.save!
  end
end
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
