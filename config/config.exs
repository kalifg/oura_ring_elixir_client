import Config

# Configure the OuraRing client
# You can set these values here or via environment variables

# config :oura_ring,
#   access_token: System.get_env("OURA_PERSONAL_ACCESS_TOKEN"),
#   base_url: "https://api.ouraring.com/v2"

# Import environment-specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
if File.exists?("config/#{config_env()}.exs") do
  import_config "#{config_env()}.exs"
end
