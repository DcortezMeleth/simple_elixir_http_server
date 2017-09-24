defmodule DateUtilsTest do
  use ExUnit.Case
  doctest DateUtils

  test "should return current date for wrong date" do
    dt = DateUtils.parse_date("wrong_date")
    assert Timex.now |> Timex.shift(minutes: -1) |> Timex.before?(dt)
  end
end
