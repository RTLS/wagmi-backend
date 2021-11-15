defmodule SharedUtils.Logger do
  @moduledoc """
  Functions that make logging easier
  """
  require Logger

  def debug(identifier, message), do: log(:debug, identifier, message)
  def info(identifier, message), do: log(:info, identifier, message)
  def warn(identifier, message), do: log(:warn, identifier, message)

  def error(error), do: log(:error, error.__struct__, error.message)

  def error(identifier, message), do: log(:error, identifier, message)

  def error_with_stack(identifier, message) do
    log_with_stacktrace(:error, identifier, message)
  end

  def warn_with_stack(identifier, message) do
    log_with_stacktrace(:warn, identifier, message)
  end

  def debug_with_stack(identifier, message) do
    log_with_stacktrace(:debug, identifier, message)
  end

  def info_with_stack(identifier, message) do
    log_with_stacktrace(:info, identifier, message)
  end

  defp log_with_stacktrace(type, identifier, error) do
    log_error(type, error_message(identifier, error))
    log_error(type, Exception.format_stacktrace())
  end

  defp log(type, identifier, error) do
    log_error(type, error_message(identifier, error))
  end

  defp log_error(:debug, message), do: Logger.debug(message)
  defp log_error(:info, message), do: Logger.info(message)
  defp log_error(:warn, message), do: Logger.warn(message)
  defp log_error(:error, message), do: Logger.error(message)

  defp error_message(identifier, %{code: code, message: message, details: details}) do
    "[#{identifier}] #{code}: #{message}\n#{inspect(details)}"
  end

  defp error_message(identifier, %{code: code, message: message}) do
    "[#{identifier}] #{code}: #{message}"
  end

  defp error_message(identifier, message) when is_binary(message) do
    "[#{identifier}] #{message}"
  end

  defp error_message(identifier, message) do
    "[#{identifier}] #{inspect(message)}"
  end
end
