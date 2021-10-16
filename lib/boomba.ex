defmodule Boomba do
  @moduledoc """
  Application Supervisor
  """
  use Application

  def start(_type, _args) do
    children = [
      Boomba.StreamElements.Commands,
      Boomba.Cooldown
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
    alchemy()
  end

  def alchemy do
    token = Application.fetch_env!(:boomba, :token)
    run = Alchemy.Client.start(token)
    use Boomba.Events
    run
  end
end
