defmodule SharedUtils.Sentry do
  @moduledoc """
  Helpers for Sentry error monitoring service
  https://sentry.iesdev.com/organizations/blitz/
  """
  def set_dsn(application_module) do
    case Application.get_application(application_module) do
      nil -> raise "Sentry: can't find app for #{application_module}"
      app -> Application.put_env(:sentry, :dsn, get_dsn(app))
    end
  end

  defp get_dsn(app) do
    dsn_map = Application.fetch_env!(:sentry, :dsn_map)

    with nil <- dsn_map[app] do
      raise "Sentry: can't find sentry dsn for #{inspect(app)}\nAvailable Apps: #{inspect(Keyword.keys(dsn_map))}"
    end
  end
end
