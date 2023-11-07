defmodule Append.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AppendWeb.Telemetry,
      Append.Repo,
      {DNSCluster, query: Application.get_env(:append, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Append.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Append.Finch},
      # Start a worker by calling: Append.Worker.start_link(arg)
      # {Append.Worker, arg},
      # Start to serve requests, typically the last entry
      AppendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Append.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AppendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
