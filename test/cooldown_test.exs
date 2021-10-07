defmodule BoombaTest.Cooldown do
  use ExUnit.Case
  doctest(Boomba.Cooldown)

  alias Boomba.Cooldown
  alias Boomba.StreamElements.Command

  setup_all do
    {:ok, %{command: %Command{_id: "command_id", cooldown: %{user: 5, global: 2}}}}
  end

  test "Cooldown starts", state do
    start_supervised!(Cooldown)
    assert :ok == Cooldown.execute(state.command, "user_id")
  end

  test "registers when executing", state do
    start_supervised!(Cooldown)
    assert :ok == Cooldown.execute(state.command, "user_id")
    state = Cooldown.get_cooldowns()
    assert Map.has_key?(state, "command_id-global")
    assert Map.has_key?(state, "command_id-user_id")
  end

  test "same user before user cooldown", state do
    start_supervised!(Cooldown)
    assert :ok == Cooldown.execute(state.command, "user_id")
    assert :user_lock == Cooldown.execute(state.command, "user_id")
  end

  test "new user before global cooldown", state do
    start_supervised!(Cooldown)
    assert :ok == Cooldown.execute(state.command, "user1")
    assert :global_lock == Cooldown.execute(state.command, "user2")
  end

  test "same user after user cooldown", state do
    start_supervised!(Cooldown)
    assert :ok == Cooldown.execute(state.command, "user_id")
    :timer.sleep(:timer.seconds(3))
    assert :ok == Cooldown.execute(state.command, "user_id")
  end
end
