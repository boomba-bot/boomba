defmodule Boomba.Services.StreamElements do
  @moduledoc false

  def channel(id) do
    headers = [Authorization: Application.get_env(:boomba, :se_token)]

    case HTTPoison.get("https://api.streamelements.com/kappa/v2/channels/#{id}", headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} -> {:ok, Poison.decode!(body)}
      _ -> {:error, %{message: "failed to get channel"}}
    end
  end

  def id_for_guild(_guild_id) do
    {:ok, "5ed53ac70b3ec17e8e48de0e"}
  end
end
