defmodule Elementary.InternalTest do
  use ExUnit.Case
  alias Elementary.Internal
  import Elementary, only: [command: 1, command: 2, add_subcommand: 2]

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
end
