defmodule Boomba.Emojis do
  def emojify(message, guild_id) do
    {:ok, guild} = Alchemy.Cache.guild(guild_id)

    message
    |> String.split(" ")
    |> Enum.map(fn word ->
      case find_emoji(word, guild.emojis) do
        nil ->
          word

        emoji ->
          "#{emoji}"
      end
    end)
    |> Enum.join(" ")
  end

  def find_emoji(word, emojis) when is_binary(word) do
    emojis
    |> Enum.find(fn emoji ->
      emoji.name == word
    end)
  end
end
