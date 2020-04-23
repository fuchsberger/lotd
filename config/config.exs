# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :lotd,
  ecto_repos: [Lotd.Repo]

# Nexus API urls
config :lotd, Lotd.NexusAPI,
  user_url: "https://api.nexusmods.com/v1/users/validate.json",
  header: [
    application_name: "LOTD Inventory Manager",
    application_version: "0.1"
  ]

# Configures the endpoint
config :lotd, LotdWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "o4VDttM6WVlwFFes9c7jo+u46DrK2lKDdhC9tF2rUYiq7UMf7h5H8Xaz56KsoRdb",
  render_errors: [view: LotdWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: Lotd.PubSub,
  live_view: [ signing_salt: "yPX4HroHXx7yWYqHVUYU1EMv7QKl5WuK" ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
