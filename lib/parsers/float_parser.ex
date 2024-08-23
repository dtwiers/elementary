defmodule Elementary.Parsers.FloatParser do
  @behaviour Elementary.Parser
  @impl true
  def parse([value | rest], _opts) do
    with {result, ""} <- Float.parse(value) do
      {:ok, result, rest}
    else
      _ -> {:error, "invalid float", rest}
    end
  end

  def parse([], opts) do
    required = Keyword.get(opts, :required, false)

    if required,
      do: {:error, "missing float"},
      else: {:ok, nil, []}
  end
end
