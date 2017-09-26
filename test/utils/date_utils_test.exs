defmodule DateUtilsTest do
  use ExUnit.Case
  doctest Utils.DateUtils

  test "should return current date for unparsable date string" do
    dt = Utils.DateUtils.parse_date("wrong_date")
    assert Timex.now |> Timex.shift(minutes: -1) |> Timex.before?(dt)
  end
end
