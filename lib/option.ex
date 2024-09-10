defmodule Elementary.Option do
  @type t :: %Elementary.Option{
          name: String.t(),
          description: String.t(),
          type:
            :string
            | :boolean
            | :integer
            | :float
            | {:list, t, :space | :flag | Atom.t(), t}
            | {:atom, [Atom.t()]}
            | {:custom, any()},
          default: any(),
          aliases: [String.t()],
          required: boolean(),
          pre_validate: (String.t() -> :ok | {:error, String.t()}),
          post_validate: (any() -> :ok | {:error, String.t()})
        }

  @enforce_keys [:name, :description, :type, :default]
  defstruct [
    :name,
    :description,
    :type,
    :default,
    aliases: [],
    required: false,
    pre_validate: nil,
    post_validate: nil
  ]

  def new(name, description, type, opts \\ [])

  @spec new(String.t(), String.t(), :string | :boolean | :integer | :float,
          aliases: [String.t()],
          required: boolean(),
          pre_validate: (String.t() -> :ok | {:error, String.t()}),
          post_validate: (any() -> :ok | {:error, String.t()})
        ) :: t
  def new(name, description, type, opts)
      when type in [:string, :boolean, :integer, :float] do
    default =
      Keyword.get(
        opts,
        :default,
        case type do
          :string -> ""
          :boolean -> false
          :integer -> 0
          :float -> 0.0
        end
      )

    %Elementary.Option{
      name: name,
      description: description,
      type: type,
      default: default
    }
    |> Map.merge(Map.new(opts))
  end

  @spec new(String.t(), String.t(), {:list, t, :space | :flag | Atom.t(), t},
          aliases: [String.t()],
          required: boolean(),
          pre_validate: (String.t() -> :ok | {:error, String.t()}),
          post_validate: (any() -> :ok | {:error, String.t()})
        ) :: t
  def new(name, description, {:list, element_type, delimiter, element_option}, opts) do
    default =
      Keyword.get(opts, :default, [])

    %Elementary.Option{
      name: name,
      description: description,
      type: {:list, element_type, delimiter, element_option},
      default: default
    }
    |> Map.merge(Map.new(opts))
  end

  @spec new(String.t(), String.t(), {:atom, [Atom.t()]},
          aliases: [String.t()],
          required: boolean(),
          pre_validate: (String.t() -> :ok | {:error, String.t()}),
          post_validate: (any() -> :ok | {:error, String.t()})
        ) :: t
  def new(name, description, {:atom, choices}, opts) do
    default =
      Keyword.get(opts, :default, nil)

    %Elementary.Option{
      name: name,
      description: description,
      type: {:atom, choices},
      default: default
    }
    |> Map.merge(Map.new(opts))
  end

  def list_type(element_type, delimiter, element_option \\ nil) do
    {:list, element_type, delimiter,
     element_option ||
       %Elementary.Option{
         name: "list_item",
         description: "List item",
         type: element_type,
         default: nil
       }}
  end

  def atom_type(choices) do
    {:atom, choices}
  end

  def parse(option, args) do
    case option.type do
      :string ->
        parse_string(option, args)

      :boolean ->
        parse_boolean(option, args)

      {:list, element_type, delimiter, element_option} ->
        parse_list(option, args, element_type, delimiter, element_option)

      {:atom, choices} ->
        parse_atom(option, args, choices)
    end
  end

  def matches?(option, arg) do
    aliases =
      if option.aliases == [] do
        ["--" <> option.name]
      else
        option.aliases
      end

    Enum.member?(aliases, arg)
  end

  defp parse_string(_option, args) do
    case Enum.at(args, 0) do
      nil -> {:error, "missing string", args}
      arg -> {:ok, arg, Enum.drop(args, 1)}
    end
  end

  defp parse_boolean(_option, args) do
    case String.downcase(Enum.at(args, 0)) do
      "true" -> {:ok, true, Enum.drop(args, 1)}
      "false" -> {:ok, false, Enum.drop(args, 1)}
      _ -> {:error, "invalid boolean", args}
    end
  end

  defp parse_list(_option, args, _element_type, delimiter, element_option) do
    case delimiter do
      :space ->
        elems =
          Enum.take_while(args, fn arg -> !String.starts_with?(arg, "-") end)
          |> Enum.map(&parse(element_option, [&1]))

        {:ok, elems, Enum.drop(args, Enum.count(elems))}

      delim ->
        elems =
          String.split(Enum.at(args, 0), delim)
          |> Enum.map(&parse(element_option, [&1]))

        {:ok, elems, Enum.drop(args, 1)}
    end
  end

  defp parse_atom(_option, args, choices) do
    case Enum.at(args, 0) do
      nil ->
        {:error, "missing atom", args}

      arg ->
        if Enum.member?(choices, arg) do
          {:ok, arg, Enum.drop(args, 1)}
        else
          {:error, "invalid atom", args}
        end
    end
  end
end
