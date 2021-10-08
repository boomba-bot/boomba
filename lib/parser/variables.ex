defmodule Boomba.Parser.Variables do
  @moduledoc false

  use Timex

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

  def variable("time.until " <> utc_time, _message) do
    [hours, minutes] = utc_time |> String.split(":") |> Enum.map(fn x -> String.to_integer(x) end)

    Timex.now()
    |> Timex.set(hour: hours, minute: minutes)
    |> Timex.format!("{relative}", :relative)
  rescue
    _ -> "{invalid time}"
  end

  def variable("time." <> zone, _message) do
    case zone |> String.trim() |> String.upcase() |> Timex.now() do
      {:error, _} -> "{invalid timezone}"
      date -> date |> Timex.format!("{h24}:{m}")
    end
  end

  def variable("touser", message) do
    case message.content
         |> String.split(" ")
         |> Enum.at(1) do
      nil -> "<@#{message.author.id}>"
      content -> content
    end
  end

  def variable("random.pick " <> options, _message) do
    quoted_options =
      Regex.scan(~r/'(?:[^'\\]|\\.)*'/, options)
      |> List.flatten()

    if Enum.empty?(quoted_options) do
      options |> String.split(" ") |> Enum.random()
    else
      quoted_options
      |> Enum.random()
      |> String.replace_prefix("'", "")
      |> String.replace_suffix("'", "")
    end
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

  def variable("urlfetch " <> url, _message) do
    case HTTPoison.get(url, [], timeout: 5000, recv_timeout: 5000, follow_redirect: true) do
      {:ok, %HTTPoison.Response{body: body}} -> body |> String.slice(0..100)
      {:error, _} -> "{server error}"
    end
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
