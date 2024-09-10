# defmodule Elementary.Parsers.StringParserTest do
#   use ExUnit.Case
#   use ExUnitProperties
#   doctest Elementary.Parsers.StringParser
#
#   property "parse" do
#     check all(args <- list_of(string(:alphanumeric), min_length: 0)) do
#       with [string_arg | rest] <- args do
#         assert Elementary.Parsers.StringParser.parse(args, required: true) ==
#                  {:ok, string_arg, rest}
#       else
#         [] ->
#           assert Elementary.Parsers.StringParser.parse(args, required: true) ==
#                    {:error, "missing string"}
#       end
#     end
#   end
# end
