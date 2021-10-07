defmodule Boomba.StreamElements.Command do
  @derive [Poison.Encoder]
  defstruct [
    :cooldown,
    :aliases,
    :keywords,
    :enabled,
    :enabledOnline,
    :enabledOffline,
    :hidden,
    :cost,
    :type,
    :accessLevel,
    :_id,
    :regex,
    :reply,
    :command,
    :channel,
    :createdAt,
    :updatedAt
  ]

  defmodule Cooldown do
    @moduledoc false
    defstruct [:user, :global]
  end
end
