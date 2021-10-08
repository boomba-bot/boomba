defmodule BoombaTest.Parser.Variables do
  use ExUnit.Case
  alias Boomba.Parser.{Tree, Variables}
  doctest(Boomba.Parser.Variables)

  setup_all do
    {:ok, %{message: %{author: %{id: "168706817348730881"}, content: "!cmd arg1 arg2 arg3"}}}
  end

  test "sender/source", state do
    sender = Variables.variable("sender", state.message)
    source = Variables.variable("source", state.message)
    assert sender == "<@#{state.message.author.id}>"
    assert source == "<@#{state.message.author.id}>"
  end

  test "random.pick", state do
    reply = Variables.variable("random.pick abc def ghi", state.message)
    assert reply in ["abc", "def", "ghi"]
  end

  test "random.pick quoted", state do
    reply = Variables.variable("random.pick 'a bc' 'de f', 'g h i'", state.message)
    assert reply in ["a bc", "de f", "g h i"]
  end

  test "random.num", state do
    reply = Variables.variable("random.1-5", state.message)
    assert reply in ["1", "2", "3", "4", "5"]
  end

  test "repeat", state do
    reply = Variables.variable("repeat 3 test something ", state.message)
    assert reply == "test something test something test something"
  end

  test "touser with args", state do
    reply = Variables.variable("touser", state.message)
    assert reply == state.message.content |> String.split(" ") |> Enum.at(1)
  end

  test "touser without args" do
    reply = Variables.variable("touser", %{author: %{id: "user_id"}, content: "!cmd"})
    assert reply == "<@user_id>"
  end

  test "time.TIMEZONE", state do
    reply = Variables.variable("time.CET", state.message)
    assert reply |> String.split(":") |> Enum.count() == 2
  end

  test "time.until", state do
    reply = Variables.variable("time.until 19:25", state.message)
    assert reply != "{invalid time}"
  end
end
