defmodule Boomba.Parser.Variables do
  @moduledoc false

  def variable("sender", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  def variable("source", message, _command) do
    "<@" <> message.author.id <> ">"
  end

  def variable("random.pick " <> options, _message, _command) do
    options
    |> String.split(" ")
    |> Enum.random()
    |> String.replace_prefix("'", "")
    |> String.replace_suffix("'", "")
    |> String.replace_prefix("\"", "")
    |> String.replace_suffix("\"", "")
  end

  def variable("random." <> range, _message, _command) do
    [lower, upper] =
      range |> String.trim() |> (&Regex.split(~r{-}, &1)).() |> Enum.map(&String.to_integer(&1))

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

    content
    |> String.split(" ")
    |> tl()
    |> Enum.join(" ")
    |> String.duplicate(times)
    |> String.trim()
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
end
