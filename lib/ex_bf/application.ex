defmodule ExBf.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: ExBf.Sessions},
      {Registry, keys: :unique, name: ExBf.Cells},
      {DynamicSupervisor, name: ExBf.Sessions.Supervisor}
    ]

    opts = [strategy: :one_for_one, name: ExBf.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_session(id) do
    DynamicSupervisor.start_child(
      ExBf.Sessions.Supervisor,
      {PartitionSupervisor,
       child_spec: DynamicSupervisor, name: {:via, Registry, {ExBf.Sessions, id}}}
    )
  end
end
