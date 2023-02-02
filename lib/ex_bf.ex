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

  def parse("," <> rest, %{idx: idx} = acc) do
    idx |> ensure_process() |> get_value()
    parse(rest, acc)
  end

  def parse("." <> rest, %{idx: idx} = acc) do
    idx |> ensure_process() |> put_value()
    parse(rest, acc)
  end

  defp ensure_process(idx) do
    case ExBf.Cell.start_link(idx: idx) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp inc_value(pid), do: GenServer.cast(pid, :+)
  defp dec_value(pid), do: GenServer.cast(pid, :-)

  defp get_value(pid) do
    [value] = "" |> IO.getn() |> to_charlist()
    GenServer.cast(pid, {:",", value})
  end

  defp put_value(pid), do: GenServer.cast(pid, :.)
end
