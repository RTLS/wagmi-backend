defmodule SharedUtils.Retry do
  @moduledoc """
  Utility functions to deal retries.
  """
  @default_opts [
    initial_retry_delay: 500,
    max_retry_delay: :timer.seconds(32),
    max_retries: 10,
    # When working with throughput sensitive endpoints (e.g. Riot API) this
    # option allows us to specify the set of status codes we should *not* retry.
    disable_retry_error_codes: []
  ]

  defguard is_mfa(module, func, args) when is_atom(module) and is_atom(func) and is_list(args)

  @doc """
  Retries an operation using an exponential back-off algorithm.
  It can be use with any function as long as the function returns an
  {:ok, result} or {:error, error} tuple.
  """
  def exponential_backoff(module, func, args, opts) when is_mfa(module, func, args) do
    func = fn args -> apply(module, func, args) end
    exponential_backoff(func, args, opts)
  end

  def exponential_backoff(func, args \\ [], opts \\ []) when is_function(func) do
    case func.(args) do
      {:ok, res} ->
        {:ok, res}

      {:error, error} ->
        opts = Keyword.merge(@default_opts, opts)

        if retriable_error?(error, opts) do
          retry_exec(func, args, opts)
        else
          {:error, error}
        end
    end
  end

  defp retriable_error?(%{code: code}, opts) do
    not Enum.member?(opts[:disable_retry_error_codes], code)
  end

  defp retriable_error?(_, _), do: true

  defp retry_exec(func, args, opts, retries_count \\ 1) do
    case func.(args) do
      {:ok, res} ->
        {:ok, res}

      {:error, _error} ->
        wait_time = next_wait_time(opts[:initial_retry_delay], retries_count)

        if wait_time < opts[:max_retry_delay] do
          Process.sleep(wait_time)
          retry_exec(func, args, opts, retries_count + 1)
        else
          opts = [{:wait_time, opts[:max_retry_delay]} | opts]
          retry_exec_without_increasing_wait_time(func, args, opts, retries_count + 1)
        end
    end
  end

  defp retry_exec_without_increasing_wait_time(func, args, opts, retries_count) do
    case func.(args) do
      {:ok, res} ->
        {:ok, res}

      {:error, error} ->
        if retries_count < opts[:max_retries] do
          Process.sleep(opts[:wait_time])
          retry_exec_without_increasing_wait_time(func, args, opts, retries_count + 1)
        else
          {:error, error}
        end
    end
  end

  @doc """
  Returns the wait time before retrying an operation based on the
  current number of retries.
  The wait times increase exponentially based on the number of
  retries. (e.g. 2, 4, 8, 16, and so on...)
  """
  def next_wait_time(retry_delay, retries_count) do
    retry_delay * next_pow(retries_count) + random_number_of_milliseconds()
  end

  defp next_pow(n) do
    trunc(:math.pow(2, n + 1))
  end

  defp random_number_of_milliseconds do
    Enum.random(1..1000)
  end
end
