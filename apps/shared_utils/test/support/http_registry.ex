defmodule SharedUtils.Support.HTTPRegistry do
  @moduledoc """
  Registers different buckets of PIDs for mocking HTTP requests

  isolated_pids, which are isolated by parent PID
  and individual cache names under which PIDs are registered after the caches are created
  """

  if Mix.env() === :test do
    def start_link do
      Registry.start_link(keys: :unique, name: __MODULE__)
    end

    @doc """
    Registers the functions that needs to run to a particular key on a process.

    The with statement handles a couple of cases:
    1.) If the Pid is already registered, update the map of functions with the new function
    2.) If update_value/3 fails with error, that means that the wrong process is attempting to update.
    This may be because a test case with the same PID was just killed, the registry hadn't been updated yet,
    and the current process with the same pid (because recycling is good for the earth) tried to access that
    stale entry. So retry!

    """

    def register_responses(tuples) do
      Process.sleep(50)

      new_functions =
        Map.new(tuples, fn {action, url, func} ->
          {{action, url}, func}
        end)

      with pid when is_pid(pid) <- Process.whereis(__MODULE__),
           {:error, {:already_registered, _}} <-
             Registry.register(__MODULE__, "isolated_pids", new_functions),
           :error <-
             Registry.update_value(__MODULE__, "isolated_pids", &Map.merge(&1, new_functions)) do
        Registry.unregister(__MODULE__, "isolated_pids")
        register_responses(tuples)
      else
        nil -> raise_not_started!()
        {_, _} -> :ok
        port when is_port(port) -> :ok
      end
    end

    def register_disable do
      Process.sleep(50)

      with pid when is_pid(pid) <- Process.whereis(__MODULE__),
           {:error, {:already_registered, _}} <-
             Registry.register(__MODULE__, "disabled_pids", :disabled),
           :error <-
             Registry.update_value(__MODULE__, "disabled_pids", fn _ -> :disabled end) do
        Registry.unregister(__MODULE__, "disabled_pids")
        register_disable()
      else
        nil -> raise_not_started!()
        {_, _} -> :ok
        port when is_port(port) -> :ok
      end
    end

    def lookup_disabled_pids do
      case Process.whereis(__MODULE__) do
        pid when is_pid(pid) ->
          __MODULE__
          |> Registry.lookup("disabled_pids")
          |> Enum.map(&elem(&1, 0))

        nil ->
          raise_not_started!()
      end
    end

    def lookup_pids do
      case Process.whereis(__MODULE__) do
        pid when is_pid(pid) ->
          __MODULE__
          |> Registry.lookup("isolated_pids")
          |> Enum.map(&elem(&1, 0))

        nil ->
          raise_not_started!()
      end
    end

    def lookup_responses(pid) do
      __MODULE__
      |> Registry.lookup("isolated_pids")
      |> Enum.find(&(elem(&1, 0) === pid))
      |> case do
        nil -> {:error, :pid_not_registered}
        {_pid, functions} -> {:ok, functions}
      end
    end
  end

  defp raise_not_started! do
    raise """
    Registry not started.
    Please add the line:

    SharedUtils.Support.HTTPRegistry.start_link()

    to test_helper.exs for the current app.
    """
  end
end
