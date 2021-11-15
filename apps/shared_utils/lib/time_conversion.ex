defmodule SharedUtils.TimeConversion do
  @moduledoc """
  This module is responsible for converting times in ms/sec etc format into other formats
  or humanizing them into a human readable format
  """

  @one_second :timer.seconds(1)
  @one_minute :timer.minutes(1)
  @one_hour :timer.hours(1)
  @one_day :timer.hours(24)
  @one_week @one_day * 7
  @one_month @one_day * 30

  @doc """
  Converts ms to a human readable format

  ## Example

    iex> TimeConversion.humanize_ms(6000)
    "6.0s"
    iex> TimeConversion.humanize_ms(600)
    "600ms"
    iex> TimeConversion.humanize_ms(6500)
    "6.5s"
    iex> TimeConversion.humanize_ms(:timer.hours(2))
    "2 Hours"
    iex> TimeConversion.humanize_ms(:timer.hours(24 * 2))
    "2 Days"
    iex> TimeConversion.humanize_ms(:timer.hours(24 * 14))
    "2 Weeks"
    iex> TimeConversion.humanize_ms(:timer.hours(24 * 60))
    "2 Months"
  """
  @spec humanize_ms(integer) :: String.t()
  def humanize_ms(ms) when ms >= @one_month do
    ms
    |> ms_to_months
    |> pluralize_time("Month")
    |> humanize_secondary(ms, @one_month)
  end

  def humanize_ms(ms) when ms >= @one_week do
    ms
    |> ms_to_weeks
    |> pluralize_time("Week")
    |> humanize_secondary(ms, @one_week)
  end

  def humanize_ms(ms) when ms >= @one_day do
    ms
    |> ms_to_days
    |> pluralize_time("Day")
    |> humanize_secondary(ms, @one_day)
  end

  def humanize_ms(ms) when ms >= @one_hour do
    ms
    |> ms_to_hours
    |> pluralize_time("Hour")
    |> humanize_secondary(ms, @one_hour)
  end

  def humanize_ms(ms) when ms >= @one_minute do
    "#{ms_to_min(ms)} Min"
  end

  def humanize_ms(ms) when ms >= @one_second do
    "#{ms_to_sec(ms)}s"
  end

  def humanize_ms(ms) do
    "#{ms}ms"
  end

  defp pluralize_time(value, unit) when value === 0 or value === 1 do
    "#{value} #{unit}"
  end

  defp pluralize_time(value, unit) do
    "#{value} #{unit}s"
  end

  defp humanize_secondary(ms_string, ms, time_frame) do
    case rem(ms, time_frame) do
      0 -> ms_string
      remaining_ms -> "#{ms_string} #{humanize_ms(remaining_ms)}"
    end
  end

  @doc """
  Converts sec to ms

  ## Example

    iex> TimeConversion.sec_to_ms(6)
    6000
    iex> TimeConversion.sec_to_ms(0.5)
    500
  """
  @spec sec_to_ms(integer | float) :: integer
  def sec_to_ms(ms) do
    round(ms * @one_second)
  end

  @doc """
  Converts ms to sec

  ## Example

    iex> TimeConversion.microseconds_to_ms(6000)
    6
    iex> TimeConversion.microseconds_to_ms(60_000)
    60
  """
  @spec microseconds_to_ms(integer) :: integer
  def microseconds_to_ms(microseconds) do
    div(microseconds, 1000)
  end

  @doc """
  Converts ms to sec

  ## Example

    iex> TimeConversion.ms_to_sec(600)
    0.6
    iex> TimeConversion.ms_to_sec(6000)
    6.0
    iex> TimeConversion.ms_to_sec(6500)
    6.5
  """
  @spec ms_to_sec(integer) :: float
  def ms_to_sec(ms) do
    ms / @one_second
  end

  @doc """
  Converts ms to nearest whole sec

  ## Example

    iex> TimeConversion.ms_to_nearest_sec(600)
    1
    iex> TimeConversion.ms_to_nearest_sec(6000)
    6
    iex> TimeConversion.ms_to_nearest_sec(6500)
    7
  """
  @spec ms_to_nearest_sec(integer) :: integer
  def ms_to_nearest_sec(ms) do
    round(ms / @one_second)
  end

  @spec ms_to_min(integer) :: integer
  @doc """
  Converts ms to min

  ## Example

    iex> TimeConversion.ms_to_min(:timer.minutes(1))
    1
    iex> TimeConversion.ms_to_min(:timer.minutes(5))
    5
    iex> TimeConversion.ms_to_min(90000)
    2
  """
  def ms_to_min(ms) do
    round(ms / @one_minute)
  end

  @spec ms_to_hours(integer) :: integer
  @doc """
  Converts ms to hours

  ## Example

    iex> TimeConversion.ms_to_hours(:timer.hours(2))
    2
    iex> TimeConversion.ms_to_hours(:timer.hours(2.5))
    3
    iex> TimeConversion.ms_to_hours(:timer.hours(4.5))
    5
  """
  def ms_to_hours(ms) do
    round(ms / @one_hour)
  end

  @spec ms_to_days(integer) :: integer
  @doc """
  Converts ms to days

  ## Example

    iex> TimeConversion.ms_to_days(:timer.hours(24 * 2))
    2
    iex> TimeConversion.ms_to_days(:timer.hours(24 * 3))
    3
    iex> TimeConversion.ms_to_days(:timer.hours(24 * 3 + 13))
    4
  """
  def ms_to_days(ms) do
    round(ms / @one_day)
  end

  @spec ms_to_weeks(integer) :: integer
  @doc """
  Converts ms to weeks

  ## Example

    iex> TimeConversion.ms_to_weeks(:timer.hours(24 * 7))
    1
    iex> TimeConversion.ms_to_weeks(:timer.hours(24 * 14))
    2
    iex> TimeConversion.ms_to_weeks(:timer.hours(24 * 11))
    2
  """
  def ms_to_weeks(ms) do
    round(ms / @one_week)
  end

  @spec ms_to_months(integer) :: integer
  @doc """
  Converts ms to months

  ## Example

    iex> TimeConversion.ms_to_months(:timer.hours(24 * 30))
    1
    iex> TimeConversion.ms_to_months(:timer.hours(24 * 60))
    2
    iex> TimeConversion.ms_to_months(:timer.hours(24 * 50))
    2
  """
  def ms_to_months(ms) do
    round(ms / @one_month)
  end
end
