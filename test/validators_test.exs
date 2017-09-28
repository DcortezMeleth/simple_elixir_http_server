defmodule ValidatorsTest do
  use ExUnit.Case
  doctest Validators

  setup _context do
    {:ok, [get_valid_headers: %{:'Host' => "http://localhost:8888"},
           get_invalid_headers: %{},
           post_valid_headers: %{:'Host' => "http://localhost:8888", :'Content-Length' => 16},
           post_invalid_headers: %{:"Host" => "http://localhost:8888"},
           put_valid_headers: %{:'Host' => "http://localhost:8888", :'Content-Length' => 16},
           put_invalid_headers: %{:"Host" => "http://localhost:8888"}]}
  end

  test "GET should pass validation", context do
    assert Validators.valid?(:GET, context[:get_valid_headers], "") == true
  end

  test "GET should not pass host header validation", context do
    assert Validators.valid?(:GET, context[:get_invalid_headers], "") == false
  end

  test "POST should pass validation", context do
    assert Validators.valid?(:POST, context[:post_valid_headers], "") == true
  end

  test "POST should not pass host header validation", context do
    assert Validators.valid?(:POST, context[:post_invalid_headers], "") == false
  end

  test "PUT should pass validation", context do
    assert Validators.valid?(:PUT, context[:post_valid_headers], "") == true
  end

  test "PUT should not pass host header validation", context do
    assert Validators.valid?(:PUT, context[:post_invalid_headers], "") == false
  end

end
