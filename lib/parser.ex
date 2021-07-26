defmodule Twitchcord.Parser do
  @moduledoc """
  Parses stream element commands
  """
  alias Twitchcord.Parser.Splitter

  @spec parse(message :: any(), command :: any()) :: {:ok, String.t()}
  def parse(message, command) do
    reply =
      get_parts(Map.get(command, "reply"))
      |> Enum.map(&part(&1, message, command))
      |> Enum.join("")

    {:ok, reply}
  end

  defp get_points(string) do
    (Regex.scan(~r/\${/, string, return: :index) ++
       Regex.scan(~r/}/, string, return: :index))
    |> Enum.map(&hd(&1))
    |> Enum.sort_by(&elem(&1, 0))
  end

  @spec get_parts(string :: String.t()) :: List
  defp get_parts(string) when is_binary(string) do
    {:ok, splitter} = Splitter.start_link()

    parts = string |> get_points() |> Enum.map(&Splitter.next_symbol(splitter, &1))

    case length(parts) do
      0 ->
        [string]

      _ ->
        parts
        |> Enum.filter(fn s -> s != :ok end)
        |> Enum.map(fn s -> split(string, s) end)
    end
  end

  defp split(string, {_, start_index, end_index}) do
    string
    |> String.split_at(start_index)
    |> elem(1)
    |> String.split_at(end_index - start_index)
    |> elem(0)
    |> get_parts()
  end

  defp part(part, message, command) when is_list(part) do
    part
    |> Enum.reverse()
    |> Enum.reduce("", fn part, acc -> part(part <> acc, message, command) end)
  end

  defp part(part, message, command) when is_binary(part) do
    variable(part, message, command)
  end

  defp variable("sender", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  defp variable("source", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  defp variable("random.pick " <> options, _message, _command) do
    options
    |> String.split(" ")
    |> Enum.random()
    |> String.replace_prefix("'", "")
    |> String.replace_suffix("'", "")
    |> String.replace_prefix("\"", "")
    |> String.replace_suffix("\"", "")
  end

  defp variable("random." <> range, _message, _command) do
    [lower, upper] =
      range |> String.trim() |> (&Regex.split(~r{-}, &1)).() |> Enum.map(&String.to_integer(&1))

    Enum.random(lower..upper)
  end

  defp variable("queryescape " <> content, _message, _command) do
    content |> URI.encode()
  end

  defp variable("args", message, _command) do
    message.content |> String.split() |> tl() |> Enum.random()
  end

  defp variable("repeat " <> content, _message, _command) do
    times = content |> String.split(" ") |> hd() |> String.to_integer()

    content
    |> String.split(" ")
    |> tl()
    |> Enum.join(" ")
    |> String.duplicate(times)
    |> String.trim()
  end

  defp variable("args.word", _message, _command) do
    :notimplemented
  end

  defp variable("args.emote", _message, _command) do
    :notimplemented
  end

  defp variable("count" <> _opts, _message, _command) do
    :notimplemented
  end

  defp variable("getcount" <> _opts, _message, _command) do
    :notimplemented
  end

  defp variable(content, _message, _command) do
    content
  end

  defp is_emote(word) when is_binary(word) do
    :notimplemented
  end
end
