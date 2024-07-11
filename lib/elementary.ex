defmodule Elementary do
  @moduledoc """
  Documentation for `Elementary`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Elementary.hello()
      :world

  """
  def hello do
    :world
  end

  @enforce_keys [:name]
  defstruct [:name, epilog: nil, description: nil, options: [], subcommands: []]

  def command(name, opts \\ []) do
    %{
      name: name,
      epilog: Keyword.get(opts, :epilog, nil),
      description: Keyword.get(opts, :description, nil),
      options: [],
      subcommands: []
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

    parse_normalized(command, args, %{})
  end

  defp parse_normalized(command, args, state) do
    command_name = command.name
    result = args
  end

  defp is_option?(arg) do
    !String.starts_with?(arg, "-")
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
        String.graphemes(arg) |> Enum.drop(1) |> Enum.map(&("-" <> &1))

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
      |> Elementary.add_option(:bar, "bar", type: :string, short: "-b", long: "--bar")
      |> Elementary.add_subcommand(
        Elementary.command(name: "baz", epilog: "baz", description: "baz")
        |> Elementary.add_option(:qux, "qux", type: :string, short: "-q", long: "--qux")
      )

    command
    |> Elementary.parse(["foo", "--bar", "baz", "--qux", "quux"])
  end
end
