defmodule SharedUtils.DateTimeConversion do
  @moduledoc """
  Converts datetimes to unix timestamps
  """

  @minute_time_buckets 0..60
                       |> Stream.filter(&(rem(&1, 5) === 0))
                       |> Enum.map(&:timer.minutes/1)

  @hour_time_buckets Enum.map(1..24, &:timer.hours/1)
  @day_time_buckets Enum.map(1..7, &:timer.hours(24 * &1))

  @default_windows Enum.sort(@day_time_buckets ++ @hour_time_buckets ++ @minute_time_buckets)

  @doc """
  Converts iso8601 to datetime, raising if bad format or any offset

  ### Examples

      iex> SharedUtils.DateTimeConversion.iso8601_to_datetime!("2019-01-24T11:30:00Z")
      ~U[2019-01-24 11:30:00Z]

  """
  @spec iso8601_to_datetime!(String.t()) :: DateTime.t()
  def iso8601_to_datetime!(datetime_string) do
    {:ok, datetime, 0} = DateTime.from_iso8601(datetime_string)
    datetime
  end

  @spec naive_maybe_serialize(NaiveDateTime.t() | any) :: non_neg_integer | any
  @doc """
  Converts a naive date time to a string or returns result

  ### Examples

      iex> date = NaiveDateTime.from_iso8601!("2019-01-24T11:30:00Z")
      iex> SharedUtils.DateTimeConversion.naive_maybe_serialize(date)
      "2019-01-24T11:30:00"

      iex> SharedUtils.DateTimeConversion.naive_maybe_serialize(:hello)
      :hello
  """
  def naive_maybe_serialize(%NaiveDateTime{} = value) do
    NaiveDateTime.to_iso8601(value)
  end

  def naive_maybe_serialize(value), do: value

  @spec naive_maybe_deserialize(String.t() | any) :: NaiveDateTime.t() | any
  @doc """
  Converts a string to naive date time  or returns result

  ### Examples

      iex> SharedUtils.DateTimeConversion.naive_maybe_deserialize("2019-01-24T11:30:00Z")
      ~N[2019-01-24 11:30:00]

      iex> SharedUtils.DateTimeConversion.naive_maybe_deserialize(:hello)
      :hello
  """
  def naive_maybe_deserialize(value) when is_binary(value) do
    NaiveDateTime.from_iso8601!(value)
  end

  def naive_maybe_deserialize(value) when is_integer(value) do
    NaiveDateTime.add(NaiveDateTime.utc_now(), value, :millisecond)
  end

  def naive_maybe_deserialize(value), do: value

  @spec format_within_windows(DateTime.t()) :: String.t()
  @spec format_within_windows(DateTime.t(), list(non_neg_integer)) :: String.t()
  @doc """
  Converts a string to naive date time  or returns result

  ### Examples
      iex> date = DateTime.add(DateTime.utc_now(), :timer.hours(1) + 1000, :millisecond)
      iex> SharedUtils.DateTimeConversion.format_within_windows(date)
      "1 Hour - 2 Hours"

      iex> date = DateTime.add(DateTime.utc_now(), :timer.minutes(5) + 1000, :millisecond)
      iex> SharedUtils.DateTimeConversion.format_within_windows(date, [
      ...>  :timer.minutes(5),
      ...>  :timer.minutes(30),
      ...>  :timer.minutes(60)
      ...> ])
      "5 Min - 30 Min"

      iex> date = DateTime.add(DateTime.utc_now(), :timer.hours(1) + 1000, :millisecond)
      iex> SharedUtils.DateTimeConversion.format_within_windows(date, [
      ...>  :timer.minutes(5),
      ...>  :timer.minutes(30),
      ...>  :timer.minutes(60),
      ...>  :timer.minutes(70),
      ...>  :timer.minutes(120)
      ...> ])
      "1 Hour - 1 Hour 10 Min"

      iex> date = DateTime.add(DateTime.utc_now(), :timer.hours(2) + 1000, :millisecond)
      iex> SharedUtils.DateTimeConversion.format_within_windows(date, [
      ...>  :timer.minutes(5),
      ...>  :timer.minutes(30),
      ...>  :timer.minutes(60),
      ...>  :timer.minutes(70),
      ...>  :timer.minutes(120)
      ...> ])
      "1 Hour 10 Min - 2 Hours"

  """
  def format_within_windows(date_time, windows \\ @default_windows) do
    case find_datetime_windows(date_time, windows) do
      {window_start, nil} ->
        SharedUtils.TimeConversion.humanize_ms(window_start)

      {window_start, window_end} ->
        "#{SharedUtils.TimeConversion.humanize_ms(window_start)} - #{SharedUtils.TimeConversion.humanize_ms(window_end)}"
    end
  end

  defp find_datetime_windows(date_time, windows) do
    now = DateTime.utc_now()
    time_diff = now |> DateTime.diff(date_time, :millisecond) |> abs

    reversed_windows = Enum.reverse(windows)

    window_index =
      Enum.find_index(reversed_windows, fn window ->
        # -10 from the window because of time weirdness
        # can cause 1H to be 3599989 instead of 3600000
        time_diff >= window - 10
      end)

    case window_index do
      nil ->
        {hd(windows), Enum.at(windows, 1)}

      0 ->
        {Enum.at(reversed_windows, 1), hd(reversed_windows)}

      window_index ->
        window_start = Enum.at(reversed_windows, window_index)
        window_end = Enum.at(reversed_windows, window_index - 1)

        {window_start, window_end}
    end
  end
end
