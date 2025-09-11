namespace :events do
  desc "Backfill slugs for events"
  task backfill_slugs: :environment do
    Event.find_each do |event|
      event.slug = nil
      event.save!
    end
    puts "Slugs backfilled successfully."
  end
end
