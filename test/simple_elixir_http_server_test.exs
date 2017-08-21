defmodule HTTPServerTest do
  use ExUnit.Case
  doctest HTTPServer

  test "greets the world" do
    assert HTTPServer.hello() == :world
  end
end
