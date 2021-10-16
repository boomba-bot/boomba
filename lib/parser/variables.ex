defmodule Boomba.Parser.Variables do
  @moduledoc false

  use Timex

  alias Boomba.Services.{StreamElements, Twitter}

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

  def variable("channel", message) do
    {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
    {:ok, se_id} = StreamElements.id_for_guild(guild_id)
    {:ok, channel} = StreamElements.channel(se_id)
    Map.get(channel, "username")
  end

  def variable("channel.display_name", message) do
    {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
    {:ok, se_id} = StreamElements.id_for_guild(guild_id)
    {:ok, channel} = StreamElements.channel(se_id)
    Map.get(channel, "displayName")
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

  def variable("lasttweet." <> user, _message) do
    case Twitter.username_to_id(user) do
      {:ok, id} ->
        case Twitter.last_tweet(id) do
          {:ok, tweet} -> Twitter.tweet_id_to_url(Map.get(tweet, "id"), user)
          {:error, _} -> "no tweets found for #{user}"
        end

      {:error, _} ->
        "could not fetch tweets for #{user}"
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
      |> String.replace_prefix(~s('), "")
      |> String.replace_suffix(~s('), "")
    end
  end

  def variable("random.emote", message) do
    {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
    {:ok, guild} = Alchemy.Cache.guild(guild_id)

    try do
      emoji = guild.emojis |> Enum.random()
      "#{emoji}"
    rescue
      Enum.EmptyError -> "{no_emojis_available}"
    end
  end

  def variable("random.chatter", message) do
    {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
    {:ok, guild} = Alchemy.Cache.guild(guild_id)

    if guild.members(not nil and !Enum.empty?(guild.members)) do
      member = guild.members |> Enum.random()

      if member.nick(not nil) do
        member.nick
      else
        member.user.username
      end
    else
      "{no_members_available}"
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

  # arg variables cannot be pattern matched thus they need to be regexed in the catch-all clause
  def variable(content, message) do
    # arg range
    case Regex.run(~r/\d+:(\d+)?/, content) do
      [match | _] ->
        start_index = (match |> String.split(":") |> Enum.at(0) |> String.to_integer()) - 1

        if match |> String.split(":") |> Enum.at(1) == "" do
          [_ | items] = message.content |> String.split(" ")
          items |> Enum.take(-(Enum.count(items) - start_index)) |> Enum.join(" ")
        else
          end_index = (match |> String.split(":") |> Enum.at(1) |> String.to_integer()) - 1
          [_ | items] = message.content |> String.split(" ")
          Enum.slice(items, start_index..end_index) |> Enum.join(" ")
        end

      nil ->
        # ${args}
        case Regex.run(~r/\d+/, content) do
          [match] ->
            index = String.to_integer(match) - 1
            message.content |> String.split(" ") |> List.delete_at(0) |> Enum.at(index)

          nil ->
            content
        end
    end
  end
end
