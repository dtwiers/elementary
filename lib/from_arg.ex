defprotocol Elementary.FromArg do
  @spec from_arg(type :: atom, args :: [String.t()], opt :: Map.t()) :: {:ok, any, list} | {:error, String.t(), [String.t()]}
  def from_arg(type, args, opt)
end

defimpl Elementary.FromArg, for: Integer do
  def from_arg(:integer, args, _opt) do
    with {result, ""} <- Integer.parse(Enum.at(args, 0)) do
      {:ok, result, Enum.drop(args, 1)}
    else
      _ -> {:error, "invalid integer", args}
    end
  end
end

defimpl Elementary.FromArg, for: Float do
  def from_arg(:float, args, _opt) do
    with {result, ""} <- Float.parse(Enum.at(args, 0)) do
      {:ok, result, Enum.drop(args, 1)}
    else
      _ -> {:error, "invalid float", args}
    end
  end
end

defimpl Elementary.FromArg, for: String do
  def from_arg(:string, args, _opt) do
    {:ok, Enum.at(args, 0), Enum.drop(args, 1)}
  end
end

defimpl Elementary.FromArg, for: Boolean do
  def from_arg(:boolean, args, _opt) do
    case String.downcase(Enum.at(args, 0)) do
      "true" -> {:ok, true, Enum.drop(args, 1)}
      "false" -> {:ok, false, Enum.drop(args, 1)}
      _ -> {:error, "invalid boolean"}
    end
  end
end

defimpl Elementary.FromArg, for: List do
  def from_arg(:list, args, opt) do
    delimiter = Map.get(opts, :delimiter, ",")
    element_type = Map.get(opts, :element_type, String)

    case delimiter do
      :space ->
        elems =
          Enum.take_while(args, fn arg -> !String.starts_with?(arg, "-") end)
          |> Enum.map(
            &Elementary.FromArg.from_arg(
              element_type,
              [&1],
              opts |> Map.get(:element_opts, %{})
            )
          )

        {:ok, elems, Enum.drop(args, Enum.count(elems))}

      delim ->
        elems =
          String.split(Enum.at(args, 0), delim)
          |> Enum.map(
            &Elementary.FromArg.from_arg(
              element_type,
              [&1],
              opts |> Map.get(:element_opts, [])
            )
          )

        {:ok, elems, Enum.drop(args, 1)}
    end
  end
end

defimpl Elementary.FromArg, for: Atom do
  def from_arg(:atom, args, opt) do
    choices = Keyword.get(opt, :choices, [])
    case Enum.at(args, 0) do
      nil -> {:error, "missing atom", args}
      arg ->
        if Enum.member?(choices, arg) do
          {:ok, String.to_existing_atom(arg), Enum.drop(args, 1)}
        else
          {:error, "invalid atom", args}
        end
    end
  end
end
