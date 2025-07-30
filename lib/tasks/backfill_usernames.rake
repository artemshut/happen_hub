# lib/tasks/backfill_usernames.rake
namespace :users do
  desc "Generate usernames for users without one"
  task backfill_usernames: :environment do
    User.where(username: nil).find_each do |user|
      base = user.full_name.to_s.parameterize.underscore.gsub(/[^a-z0-9_]/, "")
      base = "user" if base.blank?

      candidate = base
      suffix = 1

      while User.exists?(username: candidate)
        candidate = "#{base}_#{suffix}"
        suffix += 1
      end

      user.update!(username: candidate)
      puts "Generated username for #{user.email}: #{user.username}"
    end
  end
end
