# Configure Solid Queue supervisor threads to align with the DB pool
SolidQueue.configure do |config|
  threads = ENV.fetch("SOLID_QUEUE_THREADS", ENV.fetch("RAILS_MAX_THREADS", 5)).to_i
  config.supervisor = { threads: threads }
end
