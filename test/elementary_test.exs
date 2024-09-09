defmodule ElementaryTest do
  use ExUnit.Case
  doctest Elementary

  test "handles equals options" do
    assert Elementary.handle_equals_option("--foo=bar") == ["--foo", "bar"]
    assert Elementary.handle_equals_option("--foo") == ["--foo"]
    assert Elementary.handle_equals_option("-f=bar") == ["-f=bar"]
    assert Elementary.handle_equals_option("-f") == ["-f"]
  end
end
