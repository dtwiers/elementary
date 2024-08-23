defmodule Elementary.Parsers.StringParser do
  @behaviour Elementary.Parser

  @impl true
  def parse([value | rest], _opts) do
    {:ok, value, rest}
  end

  def parse([], opts) do
    required = Keyword.get(opts, :required, false)

    if required,
      do: {:error, "missing string"},
      else: {:ok, nil, []}
  end
end
