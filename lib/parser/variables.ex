defmodule Boomba.Parser.Variables do
  def variable("sender", message) do
    "<@" <> message.author.id <> ">"
  end

  def variable("source", message) do
    "<@" <> message.author.id <> ">"
  end

  def variable("user", message) do
    message.author.username
  end

  def variable("user.name", message) do
    message.author.username
  end

  def variable("random.pick " <> options, _message) do
    options
    |> String.split(" ")
    |> Enum.random()
    |> String.replace_prefix("'", "")
    |> String.replace_suffix("'", "")
    |> String.replace_prefix("\"", "")
    |> String.replace_suffix("\"", "")
  end

  def variable("random." <> range, _message) do
    [lower, upper] =
      range |> String.trim() |> (&Regex.split(~r{-}, &1)).() |> Enum.map(&String.to_integer(&1))

    Enum.random(lower..upper) |> Integer.to_string()
  end

  def variable("queryescape " <> content, _message) do
    content |> URI.encode()
  end

  def variable("pathescape" <> content, _message) do
    content |> URI.encode_www_form()
  end

  def variable("repeat " <> content, _message) do
    times = content |> String.split(" ") |> hd() |> String.to_integer()

    content
    |> String.split(" ")
    |> tl()
    |> Enum.join(" ")
    |> String.duplicate(times)
    |> String.trim()
  end

  def variable("args", _message) do
    "args"
  end

  def variable("args.word", _message) do
    "args.word"
  end

  def variable("args.emote", _message) do
    "args.emote"
  end

  def variable("count" <> _opts, _message) do
    "count"
  end

  def variable("getcount" <> _opts, _message) do
    "count"
  end

  def variable(content, _message) do
    content
  end
end
