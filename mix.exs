defmodule Lotd.MixProject do
  use Mix.Project

  def project do
    [
      app: :lotd,
      version: "2.0.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Lotd.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.12.1"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18"},
      {:httpoison, "~> 2.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.17"},
      {:jason, "~> 1.1"},
      {:plug_cowboy, "~> 2.1"},
      {:fuzzy_compare, "~> 1.0"},
      {:tailwind, "~> 0.2.2", runtime: Mix.env() == :dev},
      {:heroicons, "~> 0.5.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": [
        "tailwind lotd --minify",
        "esbuild lotd --minify",
        "phx.digest"
      ]
    ]
  end
end
