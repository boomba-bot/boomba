defmodule BoombaTest.Parser.Splitter do
  use ExUnit.Case
  alias Boomba.Parser.Splitter

  setup do
    {:ok, pid} = Splitter.start_link()
    {:ok, %{pid: pid}}
  end

  test "default state", state do
    state = Splitter.state(state.pid)
    assert state == %{debt: 0, index: 0}
  end

  test "range", state do
    points = [[{4, 2}], [{12, 1}]]

    splits =
      points
      |> Enum.map(fn p -> Splitter.next_symbol(state.pid, hd(p)) end)
      |> Enum.filter(fn p -> p != :ok end)

    assert splits == [{:split, 0, 4}, {:split, 6, 12}]
  end

  test "single variable", state do
    {:split, start_index, end_index} = Splitter.next_symbol(state.pid, {4, 2})
    assert {0, 4} == {start_index, end_index}
    {:split, start_index, end_index} = Splitter.next_symbol(state.pid, {8, 1})
    assert {6, 8} == {start_index, end_index}
  end

  test "consecutive variables", state do
    Splitter.next_symbol(state.pid, {4, 2})
    {:split, start_index, end_index} = Splitter.next_symbol(state.pid, {8, 1})
    assert {6, 8} == {start_index, end_index}

    Splitter.next_symbol(state.pid, {12, 2})
    {:split, start_index, end_index} = Splitter.next_symbol(state.pid, {16, 1})
    assert {14, 16} == {start_index, end_index}
  end

  test "nested variables", state do
    Splitter.next_symbol(state.pid, {4, 2})
    Splitter.next_symbol(state.pid, {8, 2})
    Splitter.next_symbol(state.pid, {12, 1})
    {:split, start_index, end_index} = Splitter.next_symbol(state.pid, {16, 1})
    assert {6, 16} == {start_index, end_index}
  end
end
