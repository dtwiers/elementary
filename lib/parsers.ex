defmodule Elementary.Parsers do
  def float(str, opts \\ []) do
    case Float.parse(str) do
      {float, ""} ->
        cond do
          opts[:min] && float < opts[:min] ->
            {:error, "must be greater than or equal to #{opts[:min]}"}

          opts[:max] && float > opts[:max] ->
            {:error, "must be less than or equal to #{opts[:max]}"}

          opts[:validation] ->
            case opts[:validation].(float) do
              {:error, msg} ->
                {:error, msg}

              _ ->
                {:ok, float}
            end

          true ->
            {:ok, float}
        end

      _ ->
        {:error, "invalid float: #{str}"}
    end
  end

  def integer(str, opts \\ []) do
    case Integer.parse(str) do
      {int, ""} ->
        cond do
          opts[:min] && int < opts[:min] ->
            {:error, "must be greater than or equal to #{opts[:min]}"}

          opts[:max] && int > opts[:max] ->
            {:error, "must be less than or equal to #{opts[:max]}"}

          opts[:validation] ->
            case opts[:validation].(int) do
              {:error, msg} ->
                {:error, msg}

              _ ->
                {:ok, int}
            end

          true ->
            {:ok, int}
        end

      _ ->
        {:error, "invalid integer: #{str}"}
    end
  end

  def string(str, opts \\ []) do
    cond do
      opts[:min_length] && String.length(str) < opts[:min_length] ->
        {:error, "must be greater than or equal to #{opts[:min_length]}"}

      opts[:max_length] && String.length(str) > opts[:max_length] ->
        {:error, "must be less than or equal to #{opts[:max_length]}"}

      opts[:regex] && !Regex.match?(opts[:regex], str) ->
        {:error, "invalid string"}

      opts[:validation] ->
        case opts[:validation].(str) do
          {:error, msg} ->
            {:error, msg}

          _ ->
            {:ok, str}
        end

    end

    {:ok, str}
  end

  def atom_enum(str, choices, _opts \\ []) do
    atomized = String.to_atom(str)

    if Enum.member?(choices, atomized) do
      {:ok, atomized}
    else
      {:error, "invalid enum: #{str}"}
    end
  end

  def string_enum(str, choices, _opts \\ []) do
    if Enum.member?(choices, str) do
      {:ok, str}
    else
      {:error, "invalid enum: #{str}"}
    end
  end

  def path(str, _opts \\ []) do
    if File.dir?(str) do
      {:ok, str}
    else
      {:error, "invalid path: #{str}"}
    end
  end
end
