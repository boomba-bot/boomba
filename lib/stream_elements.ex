defmodule Boomba.StreamElements do
  require IEx
  alias Boomba.StreamElements.Command
  @moduledoc """
  Get commands and other stream elements data for a guild
  """

  use GenServer

  ## Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: __MODULE__])
  end

  @spec get_commands(guild_id :: String.t()) :: {:ok, List} | :error
  def get_commands(guild_id) do
    GenServer.call(__MODULE__, {:get_commands, guild_id}, 20000)
  end

  ## Server callbacks

  @impl true
  def init(:ok) do
    {:ok, :ets.new(:commands, [:protected, :set])}
  end

  @impl true
  def handle_call({:get_commands, guild_id}, _from, table) do
    case :ets.lookup(table, guild_id) do
      [{^guild_id, commands}] ->
        {:reply, {:ok, commands}, table}

      [] ->
        case get_commands_from_api(guild_id) do
          :error ->
            {:reply, :error, table}

          commands ->
            :ets.insert(table, {guild_id, commands})
            {:reply, {:ok, commands}, table}
        end
    end
  end

  ## Helper functions

  defp get_commands_from_api(guild_id) do
    token = Application.fetch_env!(:boomba, :se_token)
    headers = [Authorization: "Bearer #{token}"]

    case get_url(guild_id) do
      {:error, reason} -> {:error, reason}
      url -> HTTPoison.get(url, headers) |> parse_response()
    end
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body |> Poison.decode!(as: [%Command{cooldown: %Command.Cooldown{}}])
  end

  defp parse_response({:ok, %HTTPoison.Response{status_code: 404}}) do
    :notfound
  end

  defp parse_response({:ok, response}) do
    {:error, response.status_code}
  end

  defp parse_response({:error, reason}) do
    {:error, reason}
  end

  defp get_url(guild_id) do
    case Map.fetch(se_ids(), guild_id) do
      {:ok, value} ->
        "https://api.streamelements.com/kappa/v2/bot/commands/#{value}"

      :error ->
        {:error, "stream elements id not found"}
    end
  end

  defp se_ids do
    %{
      "406167664596090883" => "5dd5683a71f3d374753a06c5",
      "793834847214501898" => "5dd5683a71f3d374753a06c5",
      "662462923905433610" => "5dd5683a71f3d374753a06c5"
    }
  end
end
