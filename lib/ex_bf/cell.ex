defmodule ExBf.Cell do
  @moduledoc false
  use GenServer

  def start_link(0, name: name) do
    GenServer.start_link(__MODULE__, 0, name: name)
  end

  @impl GenServer
  def init(0), do: raise(inspect({:ok, 0}))
end
