defmodule BoombaTest.StreamElements do
  use ExUnit.Case

  setup do
    {:ok, pid} = Boomba.StreamElements.start_link()
    {:ok, %{pid: pid}}
  end

  test "get commands from api" do
    {:ok, commands} = Boomba.StreamElements.get_commands("406167664596090883")
    assert is_list(commands)
  end
end
