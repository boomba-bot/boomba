defmodule Boomba.Services.Twitter do
  @moduledoc false

  def username_to_id(name) when is_binary(name) do
    headers = [Authorization: "Bearer #{Application.fetch_env!(:boomba, :twitter)}"]

    case HTTPoison.get("https://api.twitter.com/2/users/by/username/#{name}", headers) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        body = Poison.decode!(body)

        if Map.has_key?(body, "error") do
          {:error, %{message: "could not find user", reason: body}}
        else
          id = body |> Map.get("data") |> Map.get("id")
          {:ok, id}
        end

      {:ok, %HTTPoison.Response{body: body}} ->
        {:error, %{message: "could not find user", reason: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, %{message: "could not find user", reason: reason}}
    end
  end

  def last_tweet(id) do
    headers = [Authorization: "Bearer #{Application.fetch_env!(:boomba, :twitter)}"]

    case HTTPoison.get(
           "https://api.twitter.com/2/users/#{id}/tweets?tweet.fields=in_reply_to_user_id",
           headers
         ) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        body = Poison.decode!(body)

        if Map.has_key?(body, "error") or Map.has_key?(body, "errors") do
          {:error, %{message: "could not get latest tweets of user", reason: body}}
        else
          tweets =
            body
            |> Map.get("data")
            |> Enum.filter(fn tweet -> !Map.has_key?(tweet, "in_reply_to_user_id") end)
            |> List.first()

          case tweets do
            nil -> {:error, %{message: "no tweets found for user"}}
            tweet -> {:ok, tweet}
          end
        end
    end
  end

  def tweet_id_to_url(id, user_name) do
    "https://twitter.com/#{user_name}/status/#{id}"
  end
end
