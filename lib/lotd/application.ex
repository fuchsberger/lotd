defmodule Lotd.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      Lotd.Repo,
      # Start the Telemetry supervisor
      LotdWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Lotd.PubSub},
      # Start the endpoint when the application starts
      LotdWeb.Endpoint
      # Starts a worker by calling: Lotd.Worker.start_link(arg)
      # {Lotd.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lotd.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LotdWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
