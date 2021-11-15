defmodule SharedUtils.ConfigEnforcerTest do
  use ExUnit.Case, async: true

  defmodule EnforcedConfig do
    @enforce_keys [:a]
    defstruct [:a, b: 10]
  end

  doctest SharedUtils.ConfigEnforcer
end
