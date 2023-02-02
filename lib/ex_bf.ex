defmodule ExBf do
  @moduledoc """
  Documentation for `ExBf`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExBf.parse("><>")
      %{idx: 1}

      iex> ExBf.parse(">>>")
      %{idx: 3}

      iex> ExBf.parse(">++")
      %{idx: 1}
  """
  @spec parse(str :: binary(), acc :: map()) :: any()
  def parse(str, acc \\ %{idx: 0})

  def parse("", %{} = acc), do: acc

  def parse(">" <> rest, acc) do
    parse(rest, Map.update!(acc, :idx, &(&1 + 1)))
  end

  def parse("<" <> rest, acc) do
    parse(rest, Map.update!(acc, :idx, &(&1 - 1)))
  end

  def parse("+" <> rest, %{idx: idx} = acc) do
    idx |> ensure_process() |> inc_value()
    parse(rest, acc)
  end

  def parse("-" <> rest, %{idx: idx} = acc) do
    idx |> ensure_process() |> dec_value()
    parse(rest, acc)
  end

  defp ensure_process(idx) do
    name = {:via, Registry, {ExBf.Cells, idx}}

    case ExBf.Cell.start_link(0, name: name) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp inc_value(pid), do: GenServer.cast(pid, :+)
  defp dec_value(pid), do: GenServer.cast(pid, :-)
end
