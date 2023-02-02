defmodule ExBfTest do
  use ExUnit.Case
  doctest ExBf

  import ExUnit.CaptureIO

  test "prints the value" do
    assert capture_io(fn ->
             ["." | List.duplicate(["+"], 65)]
             |> Enum.reverse()
             |> Enum.join()
             |> ExBf.parse()

             Process.sleep(1_000)
           end) == "A"
  end
end
