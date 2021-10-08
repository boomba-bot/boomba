defmodule BoombaTest.Services.Twitter do
  use ExUnit.Case

  alias Boomba.Services.Twitter

  test "user to id" do
    case Twitter.username_to_id("xunafay_") do
      {:ok, id} -> assert id == "1285810488954310656"
      {:error, error} -> flunk(inspect(error))
    end
  end

  test "last tweet" do
    {:ok, id} = Twitter.username_to_id("Annie_Dro")

    case Twitter.last_tweet(id) do
      {:ok, tweet} -> assert true
      {:error, error} -> error == "could not get latest tweets of user"
    end
  end
end
