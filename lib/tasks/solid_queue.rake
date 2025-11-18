namespace :db do
  namespace :queue do
    desc "Create and load the Solid Queue database schema"
    task prepare: [ "db:create:queue", "db:schema:load:queue" ]
  end
end
