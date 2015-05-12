#3FunkyMonkeys Base Application

This is a base application intended to be used as a starting point for a new Cuba application.
It contains a base setup that we've came to find useful after creating a few apps from scratch. In order to make it easier for the next application, we're creating this one, so we can clone and make just small adjustments for the new one.

##Directory tree

The application directory tree is the following

```
.
├── app.rb
├── config.ru
├── console
├── env.sh.sample
├── helpers
│   └── environment_helper.rb
├── lib
├── models
├── README.md
├── routes
│   └── base.rb
└── views
    ├── layout
    │   └── home.erb
    ├── pages
    │   └── home.erb
    └── shared
```

The `app.rb` file contains the application boot with `require` directives and some useful plugins, such as `Rack::Session::Cookie` and `Rack::Static`

```Ruby
require "cuba"
require "cuba/safe"
require "cuba/render"
require "cuba/flash"
require "sequel"

ENV["RACK_ENV"] ||= "development"
require_relative "helpers/environment_helper"
BaseApp::Helpers.init_environment(ENV["RACK_ENV"])

Cuba.plugin Cuba::Safe
Cuba.plugin Cuba::Render

Cuba.use Rack::Session::Cookie, :secret => ENV["SESSION_SECRET"]

Cuba.use Rack::Static,
  root: File.expand_path(File.dirname(__FILE__)) + "/public",
  urls: %w[/img /css /js /fonts]

Cuba.use Rack::MethodOverride

Dir["./lib/**/*.rb"].each     { |rb| require rb }
Dir["./models/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }
Dir["./helpers/**/*.rb"].each { |rb| require rb }

Cuba.plugin BaseApp::Helpers
Cuba.use Cuba::Flash

Cuba.define do
  run BaseRoutes
end
```

It also makes use of the `helpers/environment_helper.rb` which provides a method to initialize the environment.

```Ruby
module BaseApp
  module Helpers
    def self.init_environment(env)
      self.set_env(env)

      db_params = {
        'host' => ENV["DATABASE_HOST"],
        'port' => ENV["DATABASE_PORT"],
        'user' => ENV["DATABASE_USER"],
        'password' => ENV["DATABASE_PASS"],
        'db_name' => ENV["DATABASE_NAME"]
      }

      Sequel.connect("postgres://#{ENV['DATABASE_USER']}:#{ENV['DATABASE_PASS']}@#{ENV['DATABASE_HOST']}:#{ENV['DATABASE_PORT']}/#{ENV['DATABASE_NAME']}").extension(:pg_array).extension(:pg_json)
    end

    def self.set_env(env)
      filename = env.to_s + ".env.sh"

      if File.exists? filename
        env_vars = File.read(filename)
        env_vars.each_line do |var|
          name, value = var.split("=")
          if name && value
            ENV[name.strip] = value.strip
          end
        end
      end
    end
  end
end
```

It assumes Postgres as your database, because it's the one of our choice, but you should connect to any database here, as well as make other setup before the application starts.


##Default Tasks

The application has a Rakefile with 5 common utility tasks

```
rake db:migrate       # Run DB migrations on db/migrate directory
rake db:schema:dump   # Dump the DB schema to db/schema.rb
rake db:schema:load   # Load the DB schema defined in db/schema.rb
rake db:test:prepare  # Prepares test DB by copying current dev schema
rake setup            # Setup application for new name
rake test:all         # Runs all tests in test/{models/helpers/routes/lib}
```

All are pretty descriptive and pretty simple. Feel free to remove the `Rakefile` entirely if you don't use a Sequel compatible database though.

### The Setup Task

This is an utility task to help the boostrap of the new application.
The base application uses the `BaseApp` name in a few places, this task helps you define your app name and replace the `BaseApp` name in the files.
It is an interactive task and will ask you for your app name and your git repository to set your origin remote.

In case you don't want to use this task and prefer to do it manually, all it does is:

```
rm -rf .git #Removes base app git info
mv routes/base.rb routes/yourapp.rb #Renames base routes file
find ./ -type f | xargs sed -i -e 's/BaseApp/YourApp/' #Replaces BaseApp with YourApp name in every file
cp env.sh.sample development.env.sh #Copies the sample environment file for the development environment
```

After that, it will ask you for your app's git information. If you don't have or don't intend to version it under git, it will finish there.

##Dependencies

This app provides the `.gems` and `.gems-test` files listing gem dependencies for the [dep](https://rubygems.org/gems/dep) gem.

Having the gem installed you should do

```
dep install
dep install -f .gems-test
```

If you want to manage your dependencies in any other way, just remove these files and setup your own.
