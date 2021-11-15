defmodule SharedUtils.DateTime do
  @moduledoc """
  Helper functions for DateTime & NaiveDateTime
  """

  @spec naive_from_now(integer()) :: NaiveDateTime.t()
  @spec naive_from_now(integer(), System.time_unit()) :: NaiveDateTime.t()
  @doc """
  Creates a NaveDateTime with time added from now. Can sometimes roll over to the next second.

  ### Examples

      iex> time = SharedUtils.DateTime.naive_from_now(-10, :second)
      iex> difference = NaiveDateTime.diff(NaiveDateTime.utc_now(), time, :second)
      iex> Enum.member?([10, 11], difference)
      true

  """
  def naive_from_now(time, unit \\ :millisecond) do
    NaiveDateTime.add(NaiveDateTime.utc_now(), time, unit)
  end

  @spec naive_gt?(NaiveDateTime.t(), NaiveDateTime.t()) :: boolean
  @doc """
  Checks if first naive date time is after second

  ### Examples

      iex> old_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :second)
      iex> now = NaiveDateTime.utc_now()
      iex> SharedUtils.DateTime.naive_gt?(old_time, now)
      false
      iex> SharedUtils.DateTime.naive_gt?(now, old_time)
      true

  """
  def naive_gt?(time_a, time_b) do
    case NaiveDateTime.compare(time_a, time_b) do
      :eq -> false
      :gt -> true
      :lt -> false
    end
  end

  @spec naive_lt?(NaiveDateTime.t(), NaiveDateTime.t()) :: boolean
  @doc """
  Checks if first naive date time is before second

  ### Examples

      iex> old_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :second)
      iex> now = NaiveDateTime.utc_now()
      iex> SharedUtils.DateTime.naive_lt?(old_time, now)
      true
      iex> SharedUtils.DateTime.naive_lt?(now, old_time)
      false

  """
  def naive_lt?(time_a, time_b), do: naive_gt?(time_b, time_a)

  @spec naive_before_now?(NaiveDateTime.t()) :: boolean
  @doc """
  Checks if naive date time is before now

  ### Examples

      iex> old_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :second)
      iex> SharedUtils.DateTime.naive_before_now?(old_time)
      true

      iex> new_time = NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :second)
      iex> SharedUtils.DateTime.naive_before_now?(new_time)
      false

  """
  def naive_before_now?(time), do: naive_gt?(NaiveDateTime.utc_now(), time)

  @spec naive_after_now?(NaiveDateTime.t()) :: boolean
  @doc """
  Checks if naive date time is after now

  ### Examples

      iex> old_time = NaiveDateTime.add(NaiveDateTime.utc_now(), -10, :second)
      iex> SharedUtils.DateTime.naive_after_now?(old_time)
      false

      iex> new_time = NaiveDateTime.add(NaiveDateTime.utc_now(), 10, :second)
      iex> SharedUtils.DateTime.naive_after_now?(new_time)
      true

  """
  def naive_after_now?(time), do: naive_lt?(NaiveDateTime.utc_now(), time)

  @spec naive_equal_till_second?(NaiveDateTime.t(), NaiveDateTime.t()) :: boolean
  @doc """
  Checks if a naive date time is the same as an other to the second
  instead of microsecond

  ### Examples

      iex> old_time = NaiveDateTime.utc_now()
      iex> new_time = NaiveDateTime.utc_now()
      iex> SharedUtils.DateTime.naive_equal_till_second?(old_time, new_time)
      true

  """
  def naive_equal_till_second?(time_a, time_b) do
    case NaiveDateTime.diff(time_a, time_b) do
      num when num > 1 or num < -1 -> false
      _ -> true
    end
  end

  @spec naive_before?(NaiveDateTime.t(), System.time_unit(), integer) :: boolean
  @spec naive_before?(NaiveDateTime.t(), integer) :: boolean
  @doc """
  Checks if a datetime is before? duration

  ### Examples

      iex> SharedUtils.DateTime.naive_before?(NaiveDateTime.utc_now(), 1000)
      true
      iex> SharedUtils.DateTime.naive_before?(NaiveDateTime.utc_now(), -1000)
      false
  """
  def naive_before?(%NaiveDateTime{} = datetime, unit \\ :millisecond, time) do
    naive_gt?(naive_from_now(time, unit), datetime)
  end

  @spec naive_after?(NaiveDateTime.t(), System.time_unit(), integer) :: boolean
  @spec naive_after?(NaiveDateTime.t(), integer) :: boolean
  @doc """
  Checks if a datetime is after? duration

  ### Examples

      iex> SharedUtils.DateTime.naive_after?(NaiveDateTime.utc_now(), 1000)
      false

      iex> SharedUtils.DateTime.naive_after?(NaiveDateTime.utc_now(), -1000)
      true

  """

  def naive_after?(%NaiveDateTime{} = datetime, unit \\ :millisecond, time) do
    naive_gt?(datetime, naive_from_now(time, unit))
  end

  @spec equal_till_second?(DateTime.t(), DateTime.t()) :: boolean
  @doc """
  Checks if a date time is the same as an other to the second
  instead of microsecond

  ### Examples

      iex> old_time = DateTime.utc_now()
      iex> new_time = DateTime.utc_now()
      iex> SharedUtils.DateTime.equal_till_second?(old_time, new_time)
      true

  """
  def equal_till_second?(time_a, time_b) do
    case DateTime.diff(time_a, time_b, :millisecond) do
      num when num >= 1050 or num <= -1050 -> false
      _ -> true
    end
  end

  @spec after_now?(DateTime.t()) :: boolean
  @doc """
  Checks if a datetime is after now

  ### Examples

      iex> SharedUtils.DateTime.after_now?(DateTime.add(DateTime.utc_now(), 1))
      true
      iex> SharedUtils.DateTime.after_now?(DateTime.add(DateTime.utc_now(), -1))
      false

  """
  def after_now?(datetime) do
    not before_now?(datetime)
  end

  @spec before_now?(DateTime.t()) :: boolean
  @doc """
  Checks if a datetime is before? duration

  ### Examples

      iex> SharedUtils.DateTime.before_now?(DateTime.add(DateTime.utc_now(), 1))
      false
      iex> SharedUtils.DateTime.before_now?(DateTime.add(DateTime.utc_now(), -1))
      true

  """
  def before_now?(datetime) do
    gt?(DateTime.utc_now(), datetime)
  end

  @spec before?(DateTime.t(), System.time_unit(), integer) :: boolean
  @spec before?(DateTime.t(), integer) :: boolean
  @doc """
  Checks if a datetime is before? duration

  ### Examples

      iex> SharedUtils.DateTime.before?(DateTime.utc_now(), 1000)
      true
      iex> SharedUtils.DateTime.before?(DateTime.utc_now(), -1000)
      false
  """

  def before?(%DateTime{} = datetime, unit \\ :millisecond, time) do
    gt?(from_now(time, unit), datetime)
  end

  @spec after?(DateTime.t(), System.time_unit(), integer) :: boolean
  @spec after?(DateTime.t(), integer) :: boolean
  @doc """
  Checks if a datetime is after? duration

  ### Examples

      iex> SharedUtils.DateTime.after?(DateTime.utc_now(), 10)
      false

      iex> SharedUtils.DateTime.after?(DateTime.utc_now(), -10)
      true

  """

  def after?(%DateTime{} = datetime, unit \\ :millisecond, time) do
    gt?(datetime, from_now(time, unit))
  end

  @spec from_now(integer()) :: DateTime.t()
  @spec from_now(integer(), System.time_unit()) :: DateTime.t()
  @doc """
  Creates a DateTime with time added from now. Can sometimes roll over to the next second.

  ### Examples

      iex> time = SharedUtils.DateTime.from_now(-10, :second)
      iex> now = DateTime.utc_now()
      iex> difference = DateTime.diff(now, time, :second)
      iex> Enum.member?([10, 11], difference)
      true

  """
  def from_now(time, unit \\ :millisecond) do
    DateTime.add(DateTime.utc_now(), time, unit)
  end

  @spec naive_to_unix!(NaiveDateTime.t()) :: integer()
  @spec naive_to_unix!(NaiveDateTime.t(), System.time_unit()) :: integer()
  @spec naive_to_unix!(NaiveDateTime.t(), System.time_unit(), Calendar.time_zone()) :: integer()
  @doc """
  Creates a unix time stamp with NaiveDateTime

  ### Examples

      iex> now = SharedUtils.DateTime.naive_to_unix!(NaiveDateTime.utc_now(), :second)
      iex> Enum.member?([:os.system_time(:second), :os.system_time(:second) - 1], now)
      true

  """
  def naive_to_unix!(datetime, unit \\ :millisecond, timezone \\ "Etc/UTC") do
    datetime
    |> DateTime.from_naive!(timezone)
    |> DateTime.to_unix(unit)
  end

  @spec gt?(DateTime.t(), DateTime.t()) :: boolean
  @doc """
  Checks if one date time is gt than another

  ### Examples

      iex> now = DateTime.utc_now()
      iex> past = DateTime.add(DateTime.utc_now(), -10)
      iex> SharedUtils.DateTime.gt?(now, past)
      true

  """
  def gt?(%DateTime{} = datetime_a, %DateTime{} = datetime_b) do
    case DateTime.compare(datetime_a, datetime_b) do
      :gt -> true
      _ -> false
    end
  end

  @spec lt?(DateTime.t(), DateTime.t()) :: boolean
  @doc """
  Checks if one date time is lt than another

  ### Examples

      iex> now = DateTime.utc_now()
      iex> past = DateTime.add(DateTime.utc_now(), -10)
      iex> SharedUtils.DateTime.lt?(past, now)
      true

  """
  def lt?(%DateTime{} = datetime_a, %DateTime{} = datetime_b) do
    case DateTime.compare(datetime_a, datetime_b) do
      :lt -> true
      _ -> false
    end
  end

  @spec start_of_day() :: DateTime.t()
  @spec start_of_day(DateTime.t()) :: DateTime.t()
  @doc """
  Gets the start of day for a date time or current date

  ### Examples

      iex> date = DateTime.from_unix!(1614637656) # Mar 1 2021
      iex> start_of_day = SharedUtils.DateTime.start_of_day(date)
      iex> start_of_day.day
      1


  """
  def start_of_day(date_time \\ DateTime.utc_now()) do
    %{date_time | hour: 0, minute: 0, second: 0, microsecond: {0, 0}}
  end

  @spec start_of_year() :: DateTime.t()
  @spec start_of_year(DateTime.t()) :: DateTime.t()
  @doc """
  Returns a DateTime of January 1st 00:00:00 UTC for the year of the input date. If no input date is provided, the current year will be used.

  ### Examples
    iex> datetime = DateTime.from_naive!(~N[2001-02-03 04:05:06Z], "Etc/UTC")
    ~U[2001-02-03 04:05:06Z]
    iex> SharedUtils.DateTime.start_of_year(datetime)
    ~U[2001-01-01 00:00:00Z]

  """
  def start_of_year(%{year: year} \\ DateTime.utc_now()) do
    0
    |> DateTime.from_unix!()
    |> Map.put(:year, year)
  end

  @spec same_day?(NaiveDateTime.t(), NaiveDateTime.t()) :: boolean
  @spec same_day?(DateTime.t(), DateTime.t()) :: boolean
  @doc """
  Returns true or false if the dates are on the same day of year.
  This doesn't account for timezone day fluctation

  ### Examples
    iex> datetime = DateTime.from_naive!(~N[2001-02-03 04:05:06Z], "Etc/UTC")
    iex> datetime_2 = DateTime.from_naive!(~N[2001-02-03 08:05:06Z], "Etc/UTC")
    iex> SharedUtils.DateTime.same_day?(datetime, datetime_2)
    true

    iex> datetime = NaiveDateTime.utc_now()
    iex> datetime_2 = NaiveDateTime.add(datetime, :timer.hours(25), :millisecond)
    iex> SharedUtils.DateTime.same_day?(datetime, datetime_2)
    false

  """
  def same_day?(
        %DateTime{day: day, month: month, year: year},
        %DateTime{day: day, month: month, year: year}
      ),
      do: true

  def same_day?(
        %NaiveDateTime{day: day, month: month, year: year},
        %NaiveDateTime{day: day, month: month, year: year}
      ),
      do: true

  def same_day?(_, _), do: false

  @spec days_between_now(DateTime.t()) :: non_neg_integer
  @doc """
  Returns true or false if the dates are on the same day of year.
  This doesn't account for timezone day fluctation

  ### Examples
    iex> datetime = DateTime.add(DateTime.utc_now(), :timer.hours(24 * 30), :millisecond)
    iex> SharedUtils.DateTime.days_between_now(datetime)
    30

  """
  def days_between_now(date_time) do
    between(DateTime.utc_now(), date_time, :day)
  end

  def between_now(date_time, granularity) do
    between(DateTime.utc_now(), date_time, granularity)
  end

  @spec days_between(DateTime.t(), DateTime.t()) :: non_neg_integer
  @doc """
  Returns true or false if the dates are on the same day of year.
  This doesn't account for timezone day fluctation

  ### Examples

    iex> datetime = DateTime.from_naive!(~N[2001-02-03 04:05:06Z], "Etc/UTC")
    iex> datetime_2 = DateTime.from_naive!(~N[2001-02-13 08:05:06Z], "Etc/UTC")
    iex> SharedUtils.DateTime.days_between(datetime, datetime_2)
    10
    iex> SharedUtils.DateTime.days_between(datetime_2, datetime)
    10

  """
  def days_between(date_time_a, date_time_b) do
    between(date_time_a, date_time_b, :day)
  end

  def between(date_time_a, date_time_b, granularity) do
    date_time_b
    |> DateTime.diff(date_time_a, :second)
    |> ganularity_conversion(granularity)
    |> round
    |> abs
  end

  defp ganularity_conversion(time, :day), do: time / 60 / 60 / 24
  defp ganularity_conversion(time, :hour), do: time / 60 / 60
end
