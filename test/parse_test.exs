defmodule BoombaTest.Parser do
  use ExUnit.Case
  alias Boomba.Parser
  doctest(Boomba)

  setup_all do
    {:ok, %{message: %{author: %{id: "168706817348730881"}, content: "!command arg1 arg2 arg2"}}}
  end

  test "nested variables", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "Hey ${queryescape ${sender}}"})
    assert reply == "Hey %3C@168706817348730881%3E"
  end

  test "multiple variables", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "Hey ${sender} ${source}"})
    assert reply == "Hey <@168706817348730881> <@168706817348730881>"
  end

  test "queryescape", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "${queryescape  }"})
    assert reply == "%20"
  end

  test "sender", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "Hey ${sender}"})
    assert reply == "Hey <@168706817348730881>"
  end

  test "random range", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "${random.1-10}"})
    number = reply |> String.to_integer()
    assert(number > 0 and number <= 10)
  end

  test "random pick", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "${random.pick a b c}"})
    assert(reply == "a" or reply == "b" or reply == "c")
  end

  test "args", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "${args}"})
    assert(reply == "arg1" or reply == "arg2" or reply == "arg3")
  end

  test "repeat", state do
    {:ok, reply} = Parser.parse(state.message, %{"reply" => "${repeat 3 word }"})
    assert reply == "word word word"
  end
end
