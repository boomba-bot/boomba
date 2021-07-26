defmodule Twitchcord.Events do
  @moduledoc """
  Handles Alchemy Discord events
  """
  use Alchemy.Events

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
    |> get_reply(message)
    |> send_message(message.channel_id)
  end

  def send_message({:ok, content}, channel_id) do
    Alchemy.Client.send_message(
      channel_id,
      content
    )
  end

  def send_message({:error, _} = err, _message) do
    err
  end

  def is_command(content) do
    content |> String.split(" ") |> hd() |> String.starts_with?("!")
  end

  def get_reply({:ok, command}, message) do
    Twitchcord.Parser.parse(message, command)
  end

  def get_reply({:error, _} = err, _message) do
    err
  end

  def guild_for_message(message) do
    message.channel_id |> Alchemy.Cache.guild_id()
  end

  def get_guild_commands(message) do
    {:ok, guild_id} = guild_for_message(message)
    Twitchcord.StreamElements.get_commands(guild_id)
  end

  def command_from_message({:ok, commands}, message) do
    word = message.content |> String.split(" ") |> hd() |> String.replace_prefix("!", "")
    case Enum.find(commands, fn cmd -> word == Map.get(cmd, "command") end) do
      nil -> {:error, %{reason: "not found"}}
      cmd -> {:ok, cmd}
    end
  end

  def command_from_message({:error, _} = err, _message) do
    err
  end
end
