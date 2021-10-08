defmodule Boomba.Events do
  @moduledoc """
  Handles Alchemy Discord events
  """
  use Alchemy.Events
  require Logger
  alias Boomba.Parser.Tree

  Events.on_message(:on_message)

  def on_message(message) do
    if is_command(message.content) do
      parse_message(message)
    end
  end

  @spec parse_message(message :: Alchemy.Message) :: {:ok, Alchemy.Message} | {:error, map()}
  def parse_message(message) do
    get_guild_commands(message)
    |> command_from_message(message)
    |> cooldown(message)
    |> get_reply(message)
    |> emojify(message)
    |> send_message(message.channel_id)
  end

  def cooldown({:ok, command}, message) do
    case Boomba.Cooldown.execute(command, message.author.id) do
      :ok -> {:ok, command}
      _ -> {:error, "commnad is on cooldown"}
    end
  end

  def cooldown({:error, _reason} = err, _message) do
    err
  end

  def send_message({:ok, content}, channel_id) do
    Logger.debug("sending message: #{content}")

    Alchemy.Client.send_message(
      channel_id,
      content
    )
  end

  def send_message({:error, _} = err, _message) do
    Logger.error("error parsing message: #{inspect(err)}")
    err
  end

  def is_command(content) do
    content |> String.split(" ") |> hd() |> String.starts_with?("!")
  end

  def get_reply({:ok, command}, message) do
    reply =
      Tree.build(command.reply)
      |> Tree.collapse_tree(message)

    {:ok, reply}
  end

  def get_reply({:error, _} = err, _message) do
    err
  end

  def emojify({:ok, reply}, message) do
    {:ok, guild_id} = guild_for_message(message)
    {:ok, Boomba.Emojis.emojify(reply, guild_id)}
  end

  def emojify({:error, _} = err, _message) do
    err
  end

  def guild_for_message(message) do
    message.channel_id |> Alchemy.Cache.guild_id()
  end

  def get_guild_commands(message) do
    {:ok, guild_id} = guild_for_message(message)
    Boomba.StreamElements.get_commands(guild_id)
  end

  def command_from_message({:ok, commands}, message) do
    word = message.content |> String.split(" ") |> hd() |> String.replace_prefix("!", "")

    case Enum.find(commands, fn cmd -> word == cmd.command end) do
      nil -> {:error, %{reason: "not found"}}
      cmd -> {:ok, cmd}
    end
  end

  def command_from_message({:error, _} = err, _message) do
    err
  end
end
