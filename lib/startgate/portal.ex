defmodule Stargate.Portal do
  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  def open(version, encoding) do

  end

  ## Server callbacks

  def init(:ok) do
    {:ok, %{}}
  end
end
