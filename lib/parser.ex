defmodule Elementary.Parser do
  # this isn't the way to do it. it's just a placeholder.
  @callback parse(args :: [String.t()], opts :: Keyword.t()) :: {:ok, value :: any, rest :: [String.t()]} | {:error, message :: String.t()}
end
