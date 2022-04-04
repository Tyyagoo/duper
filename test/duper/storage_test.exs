defmodule Duper.Storage.Test do
  use ExUnit.Case, async: true

  alias Duper.Storage

  defp add(state, filename, hash) do
    {:noreply, new_state} = Storage.handle_cast({:add_hash, filename, hash}, state)
    new_state
  end

  defp duplicates(state) do
    {:reply, dups, ^state} = Storage.handle_call({:find_duplicates}, nil, state)
    dups
  end

  test "empty state must return no duplicates" do
    dups = duplicates(%{})
    assert Enum.empty?(dups)
  end

  test "only single hashes must return no duplicates" do
    dups =
      %{}
      |> add("aspas.txt", "JhmHSI48")
      |> add("mw.pro", "jhmHSI48")
      |> duplicates()

    assert Enum.empty?(dups)
  end

  test "must return all duplicates when hashes collide" do
    dups =
      %{}
      |> add("mw.pro", "jhmHSI48")
      |> add("aspas.txt", "JhmHSI48")
      |> add("muzera.ex", "jhmHSI48")
      |> add("hiat", "VK7hs6")
      |> add("heat", "VK7hs6")
      |> duplicates()

    assert dups |> Map.keys() |> length() == 2
    assert Map.fetch!(dups, "jhmHSI48") == ["muzera.ex", "mw.pro"]
    assert Map.fetch!(dups, "VK7hs6") == ["heat", "hiat"]
  end
end
