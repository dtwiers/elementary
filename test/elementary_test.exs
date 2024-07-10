defmodule ElementaryTest do
  use ExUnit.Case
  doctest Elementary

  test "greets the world" do
    assert Elementary.hello() == :world
  end

  test "command" do
    IO.inspect(System.argv())
  end
end
