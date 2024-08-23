defmodule Elementary.Parsers.BooleanParser do
  @behaviour Elementary.Parser
  @impl true
  def parse(args, opts) do
    name = Keyword.get(opts, :name, nil)
    value_name = Keyword.get(opts, :value_name, nil)
    case value_name do
      "no-" <> ^name -> {:ok, false, args}
      ^name -> {:ok, true, args}
      _ -> {:error, "invalid boolean", args}
    end
  end
end
