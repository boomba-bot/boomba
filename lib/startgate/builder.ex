defmodule Stargate.Builder do
  def bot() do
    token = Application.fetch_env!(:boomba, :token)
    headers = [Authorization: "Bot #{token}"]
    HTTPoison.get!("https://discord.com/api/v9/gateway/bot", headers)
  end
end
