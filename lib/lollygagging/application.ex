defmodule Lollygagging.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LollygaggingWeb.Telemetry,
      Lollygagging.Repo,
      {DNSCluster, query: Application.get_env(:lollygagging, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lollygagging.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Lollygagging.Finch},
      # Start a worker by calling: Lollygagging.Worker.start_link(arg)
      # {Lollygagging.Worker, arg},
      # Start to serve requests, typically the last entry
      LollygaggingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lollygagging.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LollygaggingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
