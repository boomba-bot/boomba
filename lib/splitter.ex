defmodule Twitchcord.Parser.Splitter do
  @moduledoc """
  Gives start and end positions of variables in a reply
  """
  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def next_symbol(pid, symbol) do
    GenServer.call(pid, {:next, symbol})
  end

  def state(pid) do
    GenServer.call(pid, :state)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{debt: 0, index: 0}}
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  # Open when none
  def handle_call({:next, {symbol_index, 2}}, _from, %{debt: 0, index: index}) do
    {:reply, {:split, index, symbol_index}, %{debt: 1, index: symbol_index + 2}}
  end

  # Open with debt
  def handle_call({:next, {_, 2}}, _from, state) do
    {:reply, :ok, Map.update!(state, :debt, fn d -> d + 1 end)}
  end

  # Invalid close
  def handle_call({:next, {_, 1}}, _from, state = %{debt: 0}) do
    {:reply, :ok, state}
  end

  # Close
  def handle_call({:next, {symbol_index, 1}}, _from, %{debt: debt, index: index}) do
    case debt do
      1 -> {:reply, {:split, index, symbol_index}, %{debt: 0, index: symbol_index + 1}}
      _ -> {:reply, :ok, %{debt: debt - 1, index: index}}
    end
  end
end
