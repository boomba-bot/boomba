defmodule BoombaTest.Parser.Tree do
  use ExUnit.Case
  alias Boomba.Parser.Tree
  doctest(Boomba.Parser.Tree)

  test "no variables" do
    assert [{"test"}] == Tree.build("test")
  end

  test "single variable" do
    assert [{"leading ", " trailing"}, {"variable"}] == Tree.build("leading ${variable} trailing")
  end

  test "adjacent variables" do
    assert [{"leading "}, {"var1"}, {" ", " trailing"}, {"var2"}] ==
             Tree.build("leading ${var1} ${var2} trailing")
  end

  test "nested variables" do
    assert [{"leading ", " trailing"}, {"level1 ", ""}, {"level2"}] ==
             Tree.build("leading ${level1 ${level2}} trailing")
  end

  test "nested adjacent variables" do
  end
end
