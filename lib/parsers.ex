defmodule Elementary.Parsers do

  defmacro float(_name, opts \\ []) do
    _max = Keyword.get(opts, :max, :infinity)
    _min = Keyword.get(opts, :min, :negative_infinity)
    _validator = Keyword.get(opts, :validator, nil)
    _array_policy = Keyword.get(opts, :array_policy, :one) # :one, :repeat, :comma, :whitespace
    _min_occurs = Keyword.get(opts, :min_occurs, 1)
    _max_occurs = Keyword.get(opts, :max_occurs, :infinity)

    quote do

    end
  end
end
