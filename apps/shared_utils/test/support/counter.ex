defmodule SharedUtils.Support.Counter do
  @moduledoc "A tiny counter module for use in tests"

  use Agent

  def start_link(opts \\ []), do: Agent.start_link(fn -> opts[:count] || 0 end, opts)
  def inc(pid, inc \\ 1), do: Agent.update(pid, &(&1 + inc))
  def count(pid), do: Agent.get(pid, & &1)
end
