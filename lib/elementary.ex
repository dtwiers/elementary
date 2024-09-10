defmodule Elementary do
  @moduledoc """
  Documentation for `Elementary`.
  """

  alias Elementary.Internal

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

  def add_option(command, option) do
    %{command | options: command.options ++ [option]}
  end

  def add_subcommand(command, subcommand) do
    %{command | subcommands: command.subcommands ++ [subcommand]}
  end

  def parse(command, args) do
    args = Internal.normalize_args(args)

    Internal.parse_naive(command, args)
  end

  def float_option(name, opts \\ []) do
    %{
      name: name,
      type: :float,
      min: Keyword.get(opts, :min, nil),
      max: Keyword.get(opts, :max, nil),
      validation: Keyword.get(opts, :validation, nil),
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def integer_option(name, opts \\ []) do
    %{
      name: name,
      type: :integer,
      min: Keyword.get(opts, :min, nil),
      max: Keyword.get(opts, :max, nil),
      validation: Keyword.get(opts, :validation, nil),
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def string_option(name, opts \\ []) do
    %{
      name: name,
      type:
        case Keyword.get(opts, :choices, nil) do
          nil -> :string
          choices -> {:string, choices}
        end,
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def boolean_option(name, opts \\ []) do
    %{
      name: name,
      type: :boolean,
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def atom_option(name, opts \\ []) do
    %{
      name: name,
      type: {:atom, Keyword.get(opts, :choices, [])},
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def path_option(name, opts \\ []) do
    %{
      name: name,
      type: :path,
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end

  def custom_option(name, parser, opts \\ []) do
    %{
      name: name,
      type: parser,
      min_appears: Keyword.get(opts, :min_appears, 0),
      max_appears: Keyword.get(opts, :max_appears, 1),
      default: Keyword.get(opts, :default, nil),
      aliases: Keyword.get(opts, :aliases, []),
      description: Keyword.get(opts, :description, nil),
      epilog: Keyword.get(opts, :epilog, nil),
      opts: Keyword.get(opts, :opts, [])
    }
  end
end
