defmodule SharedUtils.Support.HTTPSandbox do
  @moduledoc """
  For mocking out HTTP GET and POST requests in test.

  Stores a map of functions in a Registry under the PID of the test case when
  `set_get_responses/1` or `set_post_responses/1` are called.

  In test `SharedUtils.HTTP` will default to using this sandbox to get that function
  and run it, returning the response instead of hitting an external API.
  """
  @sleep 10

  alias SharedUtils.Support.HTTPRegistry

  def get_response(url, headers, options) do
    func = find!(:get, url)

    case :erlang.fun_info(func)[:arity] do
      0 -> func.()
      3 -> func.(url, headers, options)
    end
  end

  def post_response(url, headers, options) do
    func = find!(:post, url)

    case :erlang.fun_info(func)[:arity] do
      0 -> func.()
      3 -> func.(url, headers, options)
    end
  end

  @doc """
  Set sandbox responses in test. Call this function in your setup block with a list of tuples.

  The tuples have two elements:
  - The first element is either a string url or a regex that needs to match on the url
  - The second element is a 0 or 3 arity anonymous function. The arguments for the 3 arity
  are url, headers, options.


  ```elixir
  SharedUtils.Support.HTTPSandbox.set_get_responses([{"http://google.com/", fn ->
    {:ok, {"I am a response", %SharedUtils.HTTP.Response{status: 200}}}
  end}])

  # the url headers and opts can be pattern matched here to assert the correct request was sent.
  SharedUtils.Support.HTTPSandbox.set_get_responses([
    {"http://google.com/", fn url, headers, opts ->
      {:ok, {"I am a response", %SharedUtils.HTTP.Response{status: 200}}}
    end}])

  ```
  """
  def set_get_responses(tuples) do
    tuples
    |> Enum.map(fn {url, func} -> {:get, url, func} end)
    |> HTTPRegistry.register_responses()

    Process.sleep(@sleep)
  end

  def set_post_responses(tuples) do
    tuples
    |> Enum.map(fn {url, func} -> {:post, url, func} end)
    |> HTTPRegistry.register_responses()

    Process.sleep(@sleep)
  end

  def disable_http_sandbox(_context) do
    HTTPRegistry.register_disable()
    :ok
  end

  def sandbox_disabled? do
    isolated_pids = HTTPRegistry.lookup_disabled_pids()

    SharedUtils.Process.ancestors()
    |> List.insert_at(0, self())
    |> Enum.find(&(&1 in isolated_pids))
    |> case do
      nil -> false
      pid when is_pid(pid) -> true
    end
  end

  @doc """
  Finds out whether its PID or one of its ancestor's PIDs have been registered
  Returns response function or raises an error for developer
  """

  def find!(action, url) do
    isolated_pids = HTTPRegistry.lookup_pids()

    SharedUtils.Process.ancestors()
    |> List.insert_at(0, self())
    |> Enum.find(&(&1 in isolated_pids))
    |> case do
      nil -> find_response!(action, url, self())
      pid -> find_response!(action, url, pid)
    end
  end

  defp find_response!(action, url, pid) do
    key = {action, url}

    with {:ok, funcs} <- HTTPRegistry.lookup_responses(pid),
         funcs when is_map(funcs) <- Map.get(funcs, key, funcs),
         regexes <- Enum.filter(funcs, fn {{_, k}, _v} -> Regex.regex?(k) end),
         {_regex, func} when is_function(func) <-
           Enum.find(regexes, funcs, fn {{_, k}, _v} -> Regex.match?(k, url) end) do
      func
    else
      func when is_function(func) ->
        func

      {:error, :pid_not_registered} ->
        raise """
        No functions registered for #{inspect(pid)}
        Action: #{inspect(action)}
        URL: #{inspect(url)}

        ======= Use: =======
        #{format_example(action, url)}
        === in your test ===
        """

      functions when is_map(functions) ->
        functions_text =
          functions
          |> Enum.map(fn {k, v} -> "#{inspect(k)}    =>    #{inspect(v)}" end)
          |> Enum.join("\n")

        raise """
        Function not found for {action, url} in #{inspect(pid)}
        Found:
        #{functions_text}

        ======= Use: =======
        #{format_example(action, url)}
        === in your test ===
        """

      other ->
        raise """
        Unrecognized input for {action, url} in #{inspect(pid)}

        Did you use
        fn -> function() end
        in your set_get_responses/1 ?

        Found:
        #{inspect(other)}

        ======= Use: =======
        #{format_example(action, url)}
        === in your test ===
        """
    end
  end

  defp format_example(action, url) do
    """
    alias SharedUtils.Support.HTTPSandbox

    setup do
      HTTPSandbox.set_#{action}_responses([
        {#{inspect(url)}, fn _url, _headers, _options -> _response end},
        # or
        {#{inspect(url)}, fn -> _response end}
        # or
        {~r|http://na1|, fn -> _response end}
      ])
    end
    """
  end
end
