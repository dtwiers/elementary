defmodule Elementary.Internal do
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
end
