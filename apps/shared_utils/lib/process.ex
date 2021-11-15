defmodule SharedUtils.Process do
  @moduledoc false

  @spec alive?(atom | pid) :: boolean
  def alive?(atom) when is_atom(atom) do
    case Process.whereis(atom) do
      nil -> false
      pid when is_pid(pid) -> Process.alive?(pid)
    end
  end

  def alive?(pid) when is_pid(pid), do: Process.alive?(pid)

  @doc "Fetches all ancestor pids for current process, for use in test sandboxing"
  @spec ancestors :: [pid]
  def ancestors do
    Enum.flat_map([:"$callers", :"$ancestors"], &Process.get(&1, []))
  end
end
