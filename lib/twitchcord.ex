defmodule Twitchcord do
  @moduledoc """
  Application Supervisor
  """
  use Application
  alias Alchemy.Client

  def start(_type, _args) do
    children = [
      Twitchcord.StreamElements
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    alchemy()
  end

  def alchemy do
    token = Application.fetch_env!(:twitchcord, :token)
    run = Client.start(token)
    use Twitchcord.Events
    run
  end
end
