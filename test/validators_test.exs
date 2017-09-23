defmodule ValidatorsTest do
  use ExUnit.Case
  doctest Validators

  setup _context do
    {:ok, [valid_headers: %{:"Host" => "http://localhost:8888"},
           invalid_headers: %{}]}
  end

  test "should pass validation", context do
    assert Validators.validate(context[:valid_headers], "") == true
  end

  test "should not pass host header validation", context do
    assert Validators.validate(context[:invalid_headers], "") == false
  end

end
