defmodule Elementary.Parsers.IntegerParser do
  @behaviour Elementary.Parser
  @impl true
  def parse([value | rest], _opts) do
    with {result, ""} <- Integer.parse(value) do
      {:ok, result, rest}
    else
      _ -> {:error, "invalid integer", rest}
    end
  end

  def parse([], opts) do
    required = Keyword.get(opts, :required, false)

    if required,
      do: {:error, "missing integer"},
      else: {:ok, nil, []}
  end
end
