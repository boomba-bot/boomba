defmodule Boomba.Cooldown do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  # API

  def execute(command, user) do
    GenServer.call(__MODULE__, {:execute, command, user})
  end

  def get_cooldowns() do
    GenServer.call(__MODULE__, {:get_cooldowns})
  end

  # Callback

  @impl true
  def handle_call({:execute, command, user}, _from, state) do
    case {Map.has_key?(state, "#{command._id}-global"), Map.has_key?(state, "#{command._id}-#{user}")} do
      {_, true} -> {:reply, :user_lock, state}
      {true, _} -> {:reply, :global_lock, state}
      _ ->
        state = Map.put(state, "#{command._id}-global", true)
        :timer.send_after(:timer.seconds(command.cooldown.global), {:clear_lock, "#{command._id}-global"})

        state = Map.put(state, "#{command._id}-#{user}", true)
        :timer.send_after(:timer.seconds(command.cooldown.global), {:clear_lock, "#{command._id}-#{user}"})

        {:reply, :ok, state}
    end
  end

  @impl true
  def handle_call({:get_cooldowns}, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_info({:clear_lock, lock}, state) do
    {:noreply, Map.drop(state, [lock])}
  end
end
