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
