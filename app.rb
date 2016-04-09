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
Dir["./validators/**/*.rb"].each  { |rb| require rb }
Dir["./concerns/**/*.rb"].each  { |rb| require rb }
Dir["./routes/**/*.rb"].each  { |rb| require rb }
Dir["./helpers/**/*.rb"].each { |rb| require rb }

Cuba.plugin BaseApp::Helpers
Cuba.use Cuba::Flash

Cuba.define do
  run BaseRoutes
end
