defmodule Elementary.Internal do
  alias Elementary.Parsers

  def parse_naive(command, args) do
    args
    |> Stream.with_index()
    |> Stream.chunk_while(
      nil,
      fn {elem, index}, last_arg ->
        subcommands =
          command.subcommands
          |> Enum.map(& &1.name)

        cond do
          is_option(elem) ->
            cond do
              last_arg == nil ->
                {:cont, elem}

              is_tuple(last_arg) ->
                {:cont, elem}

              true ->
                {:cont, {last_arg, true}, elem}
            end

          true ->
            cond do
              elem in subcommands ->
                command = Enum.find(command.subcommands, &(&1.name == elem))
                {:halt, {:cmd, elem, parse_naive(command, Enum.drop(args, index + 1))}}

              last_arg == nil ->
                {:cont, {:pos, elem}, nil}

              is_tuple(last_arg) ->
                last_arg_name = elem(last_arg, 0)
                {:cont, {last_arg_name, elem}, {last_arg_name, elem}}

              true ->
                {:cont, {last_arg, elem}, {last_arg, elem}}
            end
        end
      end,
      fn
        {:error, msg} -> {:cont, {:error, msg}, nil}
        {:cmd, cmd, cmd_args} when is_list(cmd_args) -> {:cont, {:cmd, cmd, cmd_args}, nil}
        last_arg when is_binary(last_arg) -> {:cont, {last_arg, true}, nil}
        _ -> {:cont, nil}
      end
    )
    |> Enum.to_list()
  end

  def is_option(arg) do
    String.starts_with?(arg, "-")
  end

  def normalize_args(args) do
    args
    |> Stream.flat_map(&split_shorthand_options(&1))
    |> Stream.flat_map(&handle_equals_option(&1))
  end

  def split_shorthand_options(arg) do
    cond do
      String.starts_with?(arg, "--") ->
        [arg]

      String.starts_with?(arg, "-") ->
        split_flags =
          String.graphemes(arg)
          |> Enum.drop(1)
          |> Enum.map(&("-" <> &1))

        case Enum.find_index(split_flags, &(&1 == "-=")) do
          nil ->
            split_flags

          index ->
            flags = Enum.slice(split_flags, 0, index)

            value =
              Enum.drop(split_flags, index + 1)
              |> Enum.map(&String.replace_prefix(&1, "-", ""))
              |> Enum.join()

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

  def match_command(raw_args, command) do
    if command == nil do
      nil
    else
      {main, sub} = raw_args |> Enum.split_while(fn arg -> elem(arg, 0) != :cmd end)

      found_subcommand =
        if length(sub) > 0 do
          subcommand = Enum.at(sub, 0)
          subcommand = Enum.find(command.subcommands, &(&1.name == elem(subcommand, 1)))
          subcommand
        else
          nil
        end

      %{
        name: command.name,
        options: main |> match_options(command),
        subcommand: sub |> match_command(found_subcommand)
      }
    end
  end

  def match_options(raw_args, command) do
    options = command.options

    options
    |> Enum.reduce(%{}, fn opt, acc ->
      filtered_args = match_option_name(raw_args, opt)

      value =
        case filtered_args do
          [] ->
            if opt.type == :boolean, do: false, else: nil

          [_ | _] ->
            process_option(filtered_args, opt)
        end

      Map.put(acc, opt.name, value || opt.default)
    end)
  end

  defp match_option_name(args, option) do
    args
    |> Enum.filter(fn arg -> matches?(option, elem(arg, 0)) end)
  end

  defp matches?(option, arg) do
    aliases =
      if option.aliases == [] do
        ["--" <> option.name]
      else
        option.aliases
      end

    Enum.member?(aliases, arg)
  end

  defp process_option(args, option) do
    name = option.name

    case {option[:min_appears] || 0, option[:max_appears] || 1, length(args)} do
      {min, 1, 1} when min <= 1 -> List.first(args) |> process_single_value(option)
      {min, max, count} when min <= count and (max == :infinity or count <= max) and count > 0 ->
        with {:ok, processed_args} <- Enum.map(args, &process_single_value(&1, option)) do
          {:ok, processed_args}
        end

      {min, _max, count} when count < min and count == 0 ->
        {:error, "option error: option #{name} is required"}

      {min, _max, count} when count < min ->
        {:error, "option error: option #{name} requires at least #{min} argument(s)"}

      {_min, max, count} when count > max ->
        {:error, "option error: option #{name} accepts at most #{max} argument(s)"}

      _ ->
        {:error, "option error: min_appears or max_appears is invalid"}
    end
  end

  defp process_single_value(arg, option) do
    {:ok, value} = case option.type do
      :boolean -> {:ok, true}
      :float -> Parsers.float(elem(arg, 1), option.opts)
      :integer -> Parsers.float(elem(arg, 1), option.opts)
      :string -> Parsers.string(elem(arg, 1), option.opts)
      {:atom, choices} -> Parsers.atom_enum(elem(arg, 1), choices, option.opts)
      {:string, choices} -> Parsers.string_enum(elem(arg, 1), choices, option.opts)
      :path -> Parsers.path(elem(arg, 1), option.opts)
      func when is_function(func, 1) -> func.(elem(arg, 1))
    end
    value
  end
end
