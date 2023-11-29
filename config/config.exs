# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lotd,
  ecto_repos: [Lotd.Repo]

# Nexus API urls
config :lotd, Lotd.NexusAPI,
  admins: [811039],
  user_url: "https://api.nexusmods.com/v1/users/validate.json",
  header: [
    application_name: "LOTD Inventory Manager",
    application_version: "1.2.0"
  ]

# Configures the endpoint
config :lotd, LotdWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: LotdWeb.ErrorHTML, accepts: ~w(html json)],
  pubsub_server: Lotd.PubSub,
  live_view: [ signing_salt: "yPX4HroHXx7yWYqHVUYU1EMv7QKl5WuK" ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.41",
  default: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
