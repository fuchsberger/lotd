import Config

# Configure your database
config :lotd, Lotd.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "lotd_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :lotd, LotdWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "o4VDttM6WVlwFFes9c7jo+u46DrK2lKDdhC9tF2rUYiq7UMf7h5H8Xaz56KsoRdb",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:lotd, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:lotd, ~w(--watch)]}
  ]

# Watch static and templates for browser reloading.
config :lotd, LotdWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/lotd_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  # Include HEEx debug annotations as HTML comments in rendered markup
  debug_heex_annotations: true,
  # Enable helpful, but potentially expensive runtime checks
  enable_expensive_runtime_checks: true
