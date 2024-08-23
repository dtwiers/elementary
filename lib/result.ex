defmodule Elementary.Result do
  @type t :: %Elementary.Result{
          name: String.t(),
          options: Map.t(),
          subcommand: Elementary.Subcommand.t() | nil
        }
  @enforce_keys [:name, :options]
  defstruct [:name, :options, subcommand: nil]
end
