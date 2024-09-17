defmodule Adsb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AdsbWeb.Telemetry,
      # Adsb.Repo,
      {DNSCluster, query: Application.get_env(:adsb, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Adsb.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Adsb.Finch},
      # Start a worker by calling: Adsb.Worker.start_link(arg)
      # {Adsb.Worker, arg},
      # Start AircraftHandler
      Adsb.Aircraft.Handler,
      # Start to serve requests, typically the last entry
      AdsbWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Adsb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AdsbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
