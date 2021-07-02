defmodule Twitchcord do
  use Application
  alias Alchemy.{Client}

  def start(_type, _args) do
    token = Application.fetch_env!(:twitchcord, :token)
    run = Client.start(token)
    use Twitchcord.Events
    run
  end
end
