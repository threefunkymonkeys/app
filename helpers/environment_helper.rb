require "logging"

module BaseApp
  module Helpers
    def self.init_environment(env)
      self.set_env(env)

      if ENV.key? "DATABASE_HOST"
        db_params = {
          'host' => ENV["DATABASE_HOST"],
          'port' => ENV["DATABASE_PORT"],
          'user' => ENV["DATABASE_USER"],
          'password' => ENV["DATABASE_PASS"],
          'database' => ENV["DATABASE_NAME"]
        }

        Sequel.postgres(db_params).extension(:pg_array).extension(:pg_json)
      end
    end

    def self.set_env(env)
      filename = env.to_s + ".env.sh"

      if File.exists? filename
        env_vars = File.read(filename)
        env_vars.each_line do |var|
          name, value = var.split("=")
          if name && value
            ENV[name.strip] = value.gsub("\"", "").strip
          end
        end
      end
    end

    def logger
      log_level = ENV["LOG_LEVEL"] || :warn
      output = ENV["LOG_OUTPUT"] || STDOUT

      @@logger ||= Proc.new {
        logger = Logging.logger(output)
        logger.level = log_level
        logger
      }.call
    end
  end
end
