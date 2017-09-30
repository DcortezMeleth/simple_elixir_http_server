defmodule ValidatorsTest do
  use ExUnit.Case
  doctest Validators

  setup _context do
    {:ok, [valid_get: %Request{http_method: :GET, headers: %{:'Host' => "http://localhost:8888"}},
           invalid_get: %Request{http_method: :GET},
           valid_post: %Request{http_method: :POST, headers: 
                       %{:'Host' => "http://localhost:8888", :'Content-Length' => 16}},
           invalid_post: %Request{http_method: :POST, headers: %{:"Host" => "http://localhost:8888"}},
           valid_put: %Request{http_method: :PUT, headers: 
                       %{:'Host' => "http://localhost:8888", :'Content-Length' => 16}},
           invalid_put: %Request{http_method: :PUT, headers: %{:"Host" => "http://localhost:8888"}}]}
  end

  test "GET should pass validation", context do
    assert Validators.valid?(context[:valid_get]) == true
  end

  test "GET should not pass host header validation", context do
    assert Validators.valid?(context[:invalid_get]) == false
  end

  test "POST should pass validation", context do
    assert Validators.valid?(context[:valid_post]) == true
  end

  test "POST should not pass host header validation", context do
    assert Validators.valid?(context[:invalid_post]) == false
  end

  test "PUT should pass validation", context do
    assert Validators.valid?(context[:valid_put]) == true
  end

  test "PUT should not pass host header validation", context do
    assert Validators.valid?(context[:invalid_put]) == false
  end

end
