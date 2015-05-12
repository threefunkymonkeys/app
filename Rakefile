@env = ARGV[1].nil? ? 'development' : ARGV[1]
task @env do ;  end unless ARGV[1].nil?

namespace :db do
  desc "Run DB migrations on db/migrate directory"
  task :migrate do
    require 'sequel'
    require_relative 'helpers/environment_helper'

    Sequel.extension :migration

    env ||= ENV['RACK_ENV'] || "development"

    db = BaseApp::Helpers.init_environment(env)

    puts 'Running migrations...'

    Sequel::Migrator.run(db, "db/migrate")

    puts 'Done!'
  end

  namespace :schema do
    desc "Dump the DB schema to db/schema.rb"
    task :dump do
      require 'sequel'
      require_relative 'helpers/environment_helper'

      env ||= ENV['RACK_ENV'] || "development"

      db = BaseApp::Helpers.init_environment(env)

      db.extension :schema_dumper

      puts "Dumping schema to db/schema.rb..."

      File.open("db/schema.rb", "w") do |f|
        f.puts db.dump_schema_migration
      end

      puts "Done!"
    end

    desc "Load the DB schema defined in db/schema.rb"
    task :load do
      require 'sequel'
      require_relative 'helpers/environment_helper'

      Sequel.extension :migration

      puts "Loading schema..."
      env ||= ENV['RACK_ENV'] || "development"

      db = RepostryApp::Helpers.init_environment(env)

      migration = eval(File.read('./db/schema.rb'))

      puts "Dropping old tables..."
      db.drop_table *db.tables, cascade: true

      puts "Applying new schema..."
      migration.apply(db, :up)

      puts "Done!"
    end
  end

  namespace :test do
    desc "Prepares test DB by copying current dev schema"
    task :prepare do
      require 'sequel'

      env_val = ENV['RACK_ENV']

      ENV['RACK_ENV'] = 'development'
      Rake::Task["db:schema:dump"].invoke

      ENV['RACK_ENV'] = 'test'
      Rake::Task["db:schema:load"].invoke
    end
  end
end

namespace :test do
  @env = 'test'
  desc "Runs all tests in test/{models/helpers/routes/lib}"
  task :all do
    load_files "test/models/*.rb"
    load_files "test/helpers/*.rb"
    load_files "test/routes/*.rb"
    load_files "test/lib/*.rb"
  end
end

desc "Setup application for new name"
task :setup do
  puts "Please, enter your app name. (e.g. MyApp)" unless ARGV[1]
  app_name = ARGV[1] || STDIN.readline.strip
  puts

  if app_name == ""
    puts "\e[31m[ERROR] The application name can't be blank\e[0m"
    exit 1
  end

  puts "Setting up #{app_name}..."

  file_name = app_name.gsub(/App/,"").downcase.strip + ".rb"

  puts "Setting up files..."

  `rm -rf .git`
  `mv routes/base.rb routes/#{file_name}`
  `find ./ -type f | xargs sed -i -e 's/BaseApp/#{app_name}/'`

  puts "Do you have a git repository already? [y/N]"
  add_remote = STDIN.readline.strip

  if add_remote.downcase == "y"
    puts "Enter your git repository name [origin]"
    remote_name = STDIN.readline.strip

    remote_name = "origin" if remote_name == ""

    puts "Enter your git repository URL"
    remote_url = STDIN.readline.strip

    if remote_url == ""
      puts "\e[33m[WARNING] URL is blank. Not adding git remote\e[0m"
    else
      `git init`
      `git remote add #{remote_name} #{remote_url}`
      `git add *`
      `git commit -m "Initial layout"`
    end
  end

  puts "\e[32mDone."
  puts "Happy Coding!\e[0m"
end

def load_files(dir)
  Dir[dir].each { |file| load file }
end
