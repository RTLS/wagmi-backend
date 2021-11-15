defmodule SharedUtils.RandomTest do
  use ExUnit.Case, async: true
  alias SharedUtils.Random

  describe "percent_to_pass?" do
    test "will pass if percentage is set to 100" do
      assert Random.percent_to_pass?(100)
    end

    test "will fail if percentage is set to 0" do
      assert false === Random.percent_to_pass?(0)
    end
  end
end
