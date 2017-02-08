defmodule LinksApi.Util do
  def camelcase(word) do
    String.capitalize(String.first(word)) <>
    String.downcase(String.slice(word, 1..-1))
  end
end
