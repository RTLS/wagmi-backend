defmodule SharedUtils.RetryTest do
  use ExUnit.Case, async: true
  alias SharedUtils.Retry

  # Dummy function to test exponential backoff + MFA
  def echo(args) do
    args
  end

  describe "exponential_backoff/4" do
    test "supports MFAs" do
      assert {:ok, result} =
               Retry.exponential_backoff(SharedUtils.RetryTest, :echo, [{:ok, 123}], [])
    end
  end

  describe "exponential_backoff/3" do
    test "should return {:ok, result} if the function call succeeds" do
      func = fn _args -> {:ok, 123} end
      assert {:ok, result} = Retry.exponential_backoff(func)
    end

    test "should return {:ok, result} if the first retry succeeds" do
      func = fn cache: cache ->
        attempts = get_attempts(cache)

        if attempts === 1 do
          {:ok, 123}
        else
          inc_attempts(cache)
          {:error, "It fails the first time."}
        end
      end

      assert {:ok, result} = Retry.exponential_backoff(func, cache: new_attempts_cache())
    end

    test "should wait and retry when the function call fails" do
      func = fn cache: cache ->
        attempts = get_attempts(cache)

        if attempts > 1 do
          {:ok, 123}
        else
          inc_attempts(cache)
          {:error, "It always fails the first time."}
        end
      end

      assert {:ok, result} = Retry.exponential_backoff(func, cache: new_attempts_cache())
    end

    test "it retries until max retries" do
      error = "It always fails."
      max_retries = 4
      calls_before_starts_retrying = 1

      func = fn cache: cache ->
        inc_attempts(cache)
        {:error, error}
      end

      opts = [
        max_retries: max_retries,
        initial_retry_delay: 500,
        max_retry_delay: 200
      ]

      cache = new_attempts_cache()
      assert {:error, ^error} = Retry.exponential_backoff(func, [cache: cache], opts)

      attempts = get_attempts(cache)
      assert attempts === max_retries + calls_before_starts_retrying
    end

    test "it doesn't retries 404s on throughput constrained endpoints" do
      not_found_error = %{code: :not_found}
      max_retries = 4

      func = fn cache: cache ->
        inc_attempts(cache)
        {:error, not_found_error}
      end

      opts = [
        max_retries: max_retries,
        initial_retry_delay: 500,
        max_retry_delay: 200,
        disable_retry_error_codes: [:not_found]
      ]

      cache = new_attempts_cache()
      assert {:error, ^not_found_error} = Retry.exponential_backoff(func, [cache: cache], opts)

      attempts = get_attempts(cache)
      assert attempts === 1
    end
  end

  describe "next_wait_time/2" do
    test "wait time increases exponentially based on the number of retries" do
      retry_time_out = 500

      list_of_attempts = [
        {0, 0..2_000},
        {1, 2_000..4_000},
        {2, 4_000..8_000},
        {3, 8_000..16_000},
        {4, 16_000..32_000}
      ]

      Enum.each(
        list_of_attempts,
        fn {attempts, wait_time_range} ->
          assert Enum.member?(wait_time_range, Retry.next_wait_time(retry_time_out, attempts))
        end
      )
    end
  end

  defp get_attempts(cache) do
    [{"attempts", attempts}] = :ets.lookup(cache, "attempts")
    attempts
  end

  defp inc_attempts(cache) do
    attempts = get_attempts(cache)
    :ets.insert(cache, {"attempts", attempts + 1})
  end

  defp new_attempts_cache do
    cache = :ets.new(:cache, [:set, :private])
    :ets.insert(cache, {"attempts", 0})
    cache
  end
end
