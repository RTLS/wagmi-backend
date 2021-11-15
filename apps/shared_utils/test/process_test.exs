defmodule SharedUtils.ProcessTest do
  use ExUnit.Case, async: true

  defmodule UselessAgent do
    use Agent

    def start_link(initial_value) do
      Agent.start_link(fn -> initial_value end, name: __MODULE__)
    end
  end

  describe "alive?/1" do
    test "finds a process when it is started" do
      refute SharedUtils.Process.alive?(UselessAgent)
      assert {:ok, pid} = UselessAgent.start_link(:bananas)
      assert SharedUtils.Process.alive?(UselessAgent)
      assert SharedUtils.Process.alive?(pid)
    end
  end
end
