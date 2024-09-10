defmodule Elementary.InternalTest do
  use ExUnit.Case
  alias Elementary.Internal
  import Elementary

  describe "parse_naive" do
    test "basic naive parse" do
      command = command(name: "foo")
      args = ["--foo", "--bar", "baz"]
      result = Internal.parse_naive(command, args)
      assert result == [{"--foo", true}, {"--bar", "baz"}]
    end

    test "subcommands" do
      command =
        command("foo")
        |> add_subcommand(command("bar"))

      args = ["bar"]
      result = Internal.parse_naive(command, args)
      assert result == [{:cmd, "bar", []}]
    end

    test "subcommands get arguments attached" do
      command =
        command("foo")
        |> add_subcommand(command("bar"))

      args = ["bar", "--baz"]
      result = Internal.parse_naive(command, args)
      assert result == [{:cmd, "bar", [{"--baz", true}]}]
    end

    test "deeply nested subcommands" do
      command =
        command("foo")
        |> add_subcommand(
          command("bar")
          |> add_subcommand(command("baz"))
        )

      args = ["bar", "baz", "--bar", "foo", "blah"]
      result = Internal.parse_naive(command, args)
      assert result == [{:cmd, "bar", [{:cmd, "baz", [{"--bar", "foo"}, {"--bar", "blah"}]}]}]
    end

    test "positionals" do
      command = command("foo", opts: [positionals: [%{name: :bar, min_appears: 2}]])

      args = ["foo", "bar"]
      result = Internal.parse_naive(command, args)
      assert result == [{:pos, "foo"}, {:pos, "bar"}]
    end
  end

  test "handles equals options" do
    assert Internal.handle_equals_option("--foo=bar") == ["--foo", "bar"]
    assert Internal.handle_equals_option("--foo") == ["--foo"]
    assert Internal.handle_equals_option("-f=bar") == ["-f=bar"]
    assert Internal.handle_equals_option("-f") == ["-f"]
  end

  test "splits shorthand options" do
    assert Internal.split_shorthand_options("-fvbd") == ["-f", "-v", "-b", "-d"]
  end

  test "splits shorthand options with equals for value" do
    assert Internal.split_shorthand_options("-asdef=bar") == ["-a", "-s", "-d", "-e", "-f", "bar"]
  end

  describe "matching" do

    test "basic matching" do
      command = command("foo")
      assert Internal.match_command([{"--foo", true}], command) == %{name: "foo", options: %{}, subcommand: nil}
    end

    test "matching an option" do
      command = command("foo")
      |> add_option(boolean_option("bar"))

      assert Internal.match_command([{"--foo", true}, {"--bar", true}], command) == %{name: "foo", options: %{"bar" => true}, subcommand: nil}

      assert Internal.match_command([{"--foo", true}, {"--bar", "baz"}], command) == %{name: "foo", options: %{"bar" => true}, subcommand: nil}
    end
  end
end
