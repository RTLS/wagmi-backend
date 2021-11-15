defmodule SharedUtils.Support.IDGenerator do
  @moduledoc """
  Used for generating IDs in tests to assist with the issue of id's being
  non-unique and overflowing out of smallint range
  """

  use Agent

  alias SharedUtils.Support.IDGenerator

  @int2_max 32_767
  @name IDGenerator

  def start_link do
    case Agent.start_link(fn -> %{} end, name: @name) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, {:already_started, pid}}
    end
  end

  def int2(namespace) do
    Agent.get_and_update(@name, fn state ->
      value = Map.get(state, namespace, Enum.random(1..10_000)) + 1

      if value > @int2_max do
        raise "Int2 overflow for #{namespace} namespace. Max value is #{@int2_max}"
      else
        {value, Map.put(state, namespace, value)}
      end
    end)
  end
end
