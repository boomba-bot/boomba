defmodule TwitchcordTest.StreamElements do
  use ExUnit.Case

  setup do
    {:ok, pid} = Twitchcord.StreamElements.start_link()
    {:ok, %{pid: pid}}
  end

  test "get commands from api" do
    {:ok, commands} = Twitchcord.StreamElements.get_commands("406167664596090883")
    assert is_list(commands)
  end
end
