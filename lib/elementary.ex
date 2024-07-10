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

  def command(name, opts \\ []) do
    %{
      name: name,
      epilog: Keyword.get(opts, :epilog, ""),
      description: Keyword.get(opts, :description, ""),
      options: [],
      subcommands: []
    }
  end

  def add_option(command, name, description, opts \\ []) do
    # TODO: create struct for this thing so I can default the element_opts to the struct
    defaults = [
      type: :string,
      short: "",
      long: "",
      default: nil,
      required: false,
      choices: [],
      element_type: String,
      element_opts: [],
      delimiter: :space
    ]

    option = %{
      name: name,
      description: description,
    }
    |> Map.merge(Map.new((defaults ++ opts)))

    %{command | options: command.options ++ [option]}
  end

  def add_subcommand(command, subcommand) do
    %{command | subcommands: command.subcommands ++ [subcommand]}
  end

  def parse(command, args) do
    args =
      args
      |> split_shorthand_options()
      |> Enum.map(&handle_equals_option/1)

    args
    |> Enum.reduce([], fn arg, acc ->
      if is_option?(arg) and Enum.member?(command.options, arg) do
      end
    end)
  end

  defp is_option?(arg) do
    !String.starts_with?(arg, "-")
  end

  defp split_shorthand_options(args) do
    Enum.flat_map(args, fn arg ->
      cond do
        String.starts_with?(arg, "--") ->
          [arg]

        String.starts_with?(arg, "-") ->
          String.graphemes(arg) |> Enum.drop(1) |> Enum.map(&("-" <> &1))

        true ->
          [arg]
      end
    end)
  end

  defp handle_equals_option("--" <> arg) do
    [opt, value] = String.split(arg, "=", parts: 2)
    ["--" <> opt, value]
  end

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
