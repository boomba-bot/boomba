defmodule Twitchcord.Parser do
  def parse(message, command) do
    reply = get_parts(command.reply) |> Enum.map(&(part(&1, message, command))) |> Enum.join("")
    {:ok, reply}
  end

  def get_points(string) do
    Regex.scan(~r/\${/, string, return: :index)
      ++ Regex.scan(~r/}/, string, return: :index)
      |> Enum.map(&(hd(&1)))
      |> Enum.sort_by(&(elem(&1, 0)))
  end

  def get_parts(string) when is_binary(string) do
    {:ok, splitter} = Twitchcord.Parser.Splitter.start_link()
    parts = string |> get_points() |> Enum.map(&(Twitchcord.Parser.Splitter.next_symbol(splitter, &1)))
    case length(parts) do
      0 -> string
      _ -> parts |> Enum.filter(fn s -> s != :ok end)
        |> Enum.map(fn s -> split(string, s) end)
    end
  end

  def split(string, {_, start_index, end_index}) do
    string |> String.split_at(start_index) |> elem(1) |> String.split_at(end_index - start_index) |> elem(0) |> get_parts()
  end

  def part(part, message, command) when is_list(part) do
    part |> Enum.reverse() |> Enum.reduce("", fn part, acc -> part(part<>acc, message, command) end)
  end

  def part(part, message, command) when is_binary(part) do
    variable(part, message, command)
  end

  def variable("sender", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  def variable("source", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  def variable("random.pick " <> options, _message, _command) do
    options |> String.split(" ") |> Enum.random()
  end

  def variable("random." <> range, _message, _command) do
    [lower, upper] = range |> String.trim() |> (&Regex.split(~r{-}, &1)).() |> Enum.map(&(String.to_integer(&1)))
    Enum.random(lower..upper)
  end

  def variable("queryescape " <> content, _message, _command) do
    content |> URI.encode()
  end

  def variable("args", message, _command) do
    message.content |> String.split() |> tl() |> Enum.random()
  end

  def variable("repeat " <> content, _message, _command) do
    times = content |> String.split(" ") |> hd() |> String.to_integer()
    content |> String.split(" ") |> tl() |> Enum.join(" ") |> String.duplicate(times) |> String.trim()
  end

  def variable("args.word", _message, _command) do
    :notimplemented
  end

  def variable("args.emote", _message, _command) do
    :notimplemented
  end

  def variable("count" <> _opts, _message, _command) do
    :notimplemented
  end

  def variable("getcount" <> _opts, _message, _command) do
    :notimplemented
  end

  def variable(content, _message, _command) do
    content
  end

  def is_emote(word) when is_binary(word) do
    :notimplemented
  end
end
