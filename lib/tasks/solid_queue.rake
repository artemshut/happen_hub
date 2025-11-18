namespace :db do
  namespace :queue do
    desc "Create and migrate the Solid Queue database"
    task prepare: [ "db:create:queue", "db:migrate:queue" ]
  end
end
