defmodule Elementary do
  @moduledoc """
  Documentation for `Elementary`.
  """

  @enforce_keys [:name]
  defstruct [:name, epilog: nil, description: nil, options: [], subcommands: [], opts: []]

  def command(name, opts \\ []) do
    %{
      name: name,
      epilog: Keyword.get(opts, :epilog, nil),
      description: Keyword.get(opts, :description, nil),
      options: [],
      subcommands: [],
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def add_option(command, name, description, type, opts \\ []) do
    option = Elementary.Option.new(name, description, type, opts)
    %{command | options: command.options ++ [option]}
  end

  def add_subcommand(command, subcommand) do
    %{command | subcommands: command.subcommands ++ [subcommand]}
  end

  def parse(command, args) do
    args = normalize_args(args)

    Elementary.Internal.parse_naive(command, args)
  end

  defp normalize_args(args) do
    args
    |> Stream.flat_map(&split_shorthand_options(&1))
    |> Stream.flat_map(&handle_equals_option(&1))
  end

  def split_shorthand_options(arg) do
    cond do
      String.starts_with?(arg, "--") ->
        [arg]

      String.starts_with?(arg, "-") ->
        split_flags = String.graphemes(arg)
        |> Enum.drop(1)
        |> Enum.map(&("-" <> &1))
        case Enum.find_index(split_flags, &(&1 == "=")) do
          nil -> split_flags
          index ->
            flags = Enum.slice(split_flags, 0, index)
            value = Enum.drop(split_flags, index + 1) |> Enum.join()
            flags ++ [value]
        end

      true ->
        [arg]
    end
  end

  def handle_equals_option("--" <> arg) do
    with [opt, value] <- String.split(arg, "=", parts: 2) do
      ["--" <> opt, value]
    else
      _ -> ["--" <> arg]
    end
  end

  def handle_equals_option(arg), do: [arg]

  def foo do
    command =
      Elementary.command("foo", epilog: "foo", description: "foo")
      |> Elementary.add_option(:bar, "bar description", :string, short: "-b", long: "--bar")
      |> Elementary.add_subcommand(
        Elementary.command(name: "baz", epilog: "baz", description: "baz")
        |> Elementary.add_option(:qux, "qux", :string, short: "-q", long: "--qux")
      )

    command
    |> Elementary.parse(["foo", "--bar", "baz", "--qux", "quux"])

    # {:ok, %{name: "foo", options: %{bar: "baz", qux: "quux"}, subcommand: nil}, []}
  end
end
