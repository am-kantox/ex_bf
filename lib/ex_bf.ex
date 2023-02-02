defmodule ExBf do
  @moduledoc """
  Documentation for `ExBf`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ExBf.parse("><>", 0)
      %{id: 0, idx: 1, loops: []}

      iex> ExBf.parse("++>+++[<+>-]<?")
      5

      iex> ExBf.parse("++>+++++<[->+<]>?")
      7
  """
  @spec parse(str :: binary()) :: any()
  def parse(str, id \\ make_ref()) do
    ExBf.Application.start_session(id)
    do_parse(str, %{id: id, idx: 0, loops: []})
  end

  def do_parse("", %{loops: []} = acc), do: acc
  def do_parse("?", %{loops: [], id: id, idx: idx}), do: value({id, idx})

  def do_parse(<<sym::8, rest::binary>>, acc)
      when sym not in [?>, ?<, ?+, ?-, ?,, ?., ?[, ?], ??],
      do: do_parse(rest, acc)

  def do_parse("]" <> rest, %{loops: [{_, 0} | loops]} = acc) do
    do_parse(rest, %{acc | loops: loops})
  end

  def do_parse("]" <> rest, %{loops: [{code, _} | loops]} = acc) do
    do_parse(code <> "]" <> rest, %{acc | loops: loops})
  end

  def do_parse("[" <> rest, %{loops: [{_, 0} | _]} = acc) do
    do_parse(rest, %{acc | loops: [{"[", 0} | acc.loops]})
  end

  def do_parse("[" <> rest, %{id: id, idx: idx} = acc) do
    do_parse(rest, %{acc | loops: [{"[", value({id, idx})} | acc.loops]})
  end

  def do_parse(<<_::8, rest::binary>>, %{loops: [{_, 0} | _]} = acc) do
    do_parse(rest, acc)
  end

  def do_parse(">" <> rest, acc) do
    do_parse(rest, %{acc | idx: acc.idx + 1, loops: update_loops(acc.loops, ">")})
  end

  def do_parse("<" <> rest, acc) do
    do_parse(rest, %{acc | idx: acc.idx - 1, loops: update_loops(acc.loops, "<")})
  end

  def do_parse("+" <> rest, %{id: id, idx: idx} = acc) do
    inc_value({id, idx})
    do_parse(rest, %{acc | loops: update_loops(acc.loops, "+")})
  end

  def do_parse("-" <> rest, %{id: id, idx: idx} = acc) do
    dec_value({id, idx})
    do_parse(rest, %{acc | loops: update_loops(acc.loops, "-")})
  end

  def do_parse("," <> rest, %{id: id, idx: idx} = acc) do
    get_value({id, idx})
    do_parse(rest, %{acc | loops: update_loops(acc.loops, ",")})
  end

  def do_parse("." <> rest, %{id: id, idx: idx} = acc) do
    put_value({id, idx})
    do_parse(rest, %{acc | loops: update_loops(acc.loops, ".")})
  end

  defp ensure_process({id, idx}) do
    case ExBf.Cell.start_link(id, idx) do
      {:ok, pid} -> pid
      {:error, {:already_started, pid}} -> pid
    end
  end

  defp inc_value(id), do: id |> ensure_process() |> GenServer.cast(:+)
  defp dec_value(id), do: id |> ensure_process() |> GenServer.cast(:-)

  defp get_value(id) do
    [value] = "" |> IO.getn() |> to_charlist()
    id |> ensure_process() |> GenServer.cast({:",", value})
  end

  defp put_value(id), do: IO.write(<<value(id)>>)
  defp value(id), do: id |> ensure_process() |> GenServer.call(:.)

  defp update_loops([], _), do: []
  defp update_loops(codes, sym), do: for({code, idx} <- codes, do: {code <> sym, idx})
end
