import Config

# Configure your database
config :lotd, Lotd.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "lotd_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :lotd, LotdWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "QFnqwW38sQ6BHHcKyJfHNbutD7CEWd3D+mLgPovlEs/InWLA6e9WcNRAdFP0K/gC"
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
