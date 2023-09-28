namespace :ucb_rails_user do
  desc "Create a migration for a users table that is compatible with this gem"
  task create_users_table: :environment do
    sh "bin/rails g migration CreateUsersToo"
    new_migration_file = Dir.glob("db/migrate/*_create_users_too.rb").last
    sh "cat #{File.expand_path('../..', __FILE__)}/templates/db/create_users.rb > #{new_migration_file}"
  end
end
