defmodule ExBf.Cell do
  @moduledoc false
  use GenServer

  def start_link(idx: idx) do
    DynamicSupervisor.start_child(
      {:via, PartitionSupervisor, {ExBf.CellsSupervisors, idx}},
      %{
        id: GenServer,
        start:
          {GenServer, :start_link, [__MODULE__, 0, [name: {:via, Registry, {ExBf.Cells, idx}}]]}
      }
    )
  end

  @impl GenServer
  @doc false
  def init(0), do: {:ok, 0}

  @impl GenServer
  @doc false
  def handle_cast(:+, value), do: {:noreply, value + 1}

  @impl GenServer
  @doc false
  def handle_cast(:-, value), do: {:noreply, value - 1}

  @impl GenServer
  @doc false
  def handle_cast({:",", value}, _value), do: {:noreply, value}

  @impl GenServer
  @doc false
  def handle_cast(:., value) do
    IO.write(<<value>>)
    {:noreply, value}
  end
end
