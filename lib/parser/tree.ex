defmodule Boomba.Parser.Tree do
  @moduledoc false
  alias Boomba.Parser.Variables

  def build(message) when is_binary(message) do
    opening_brackets = Regex.scan(~r/\${/, message, return: :index)
    closing_brackets = Regex.scan(~r/}/, message, return: :index)

    brackets =
      Enum.sort(
        opening_brackets ++ closing_brackets,
        &(elem(List.first(&1), 0) < elem(List.first(&2), 0))
      )

    closing_index = closing_calc(brackets, 0)
    opening_index = opening_brackets |> Enum.at(0, [{nil}]) |> List.first() |> elem(0)

    if opening_index != nil and closing_index != nil do
      {child, trailing} = String.split_at(message, closing_index + 1)
      child = String.replace_suffix(child, "}", "")
      {leading, child} = String.split_at(child, opening_index + 2)
      leading = String.replace_suffix(leading, "${", "")

      case build(trailing) do
        [{trailing}] -> [{leading, trailing} | build(child)]
        split -> [{leading}] ++ build(child) ++ split
      end
    else
      [{message}]
    end
  end

  def collapse_tree(tree, message) do
    tree
    |> Enum.reverse()
    |> Enum.reduce("", fn el, acc ->
      case el do
        {l, r} ->
          Variables.variable(l, message) <>
            acc <> Variables.variable(r, message)

        {c} ->
          Variables.variable(c, message) <> acc
      end
    end)
  end

  defp closing_calc([[{_, 1}] | remaining], 0), do: closing_calc(remaining, 0)
  defp closing_calc([[{index, 1}] | _], 1), do: index
  defp closing_calc([[{index, 1}]], 1), do: index
  defp closing_calc([[{_, 1}] | remaining], debt), do: closing_calc(remaining, debt - 1)
  defp closing_calc([[{_, 2}] | remaining], debt), do: closing_calc(remaining, debt + 1)
  defp closing_calc([[{_, _}]], _), do: nil
  defp closing_calc([], _), do: nil
end
