defmodule Boomba.Parser.Tree do


  defstruct [:parent, :self, :children]

  def build(message) when is_binary(message) do
    first = Regex.scan(~r/\${/, message, return: :index) |> List.first()
    last = Regex.scan(~r/}/, message, return: :index) |> List.last()

    if first != nil and last != nil do
      {child, trailing} = String.split_at(message, (List.last(last) |> elem(0)) + 1)
      child = String.replace_suffix(child, "}", "")
      {leading, child} = String.split_at(child, (List.first(first) |> elem(0)) + 2)
      leading = String.replace_suffix(leading, "${", "")
      [{leading, trailing} | build(child)]
    else
      [{message}]
    end
  end
end
