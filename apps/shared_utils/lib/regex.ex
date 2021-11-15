defmodule SharedUtils.Regex do
  @moduledoc "Common regexes"

  # STRINGS

  def url do
    ~r"""
    (https?:\/\/(?:www\.|\
    (?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|\
    www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|\
    https?:\/\/(?:www\.|\
    (?!www))[a-zA-Z0-9]+\.[^\s]{2,}|\
    \www\.[a-zA-Z0-9]+\.[^\s]{2,})\
    """
  end

  def iso_8601 do
    ~r"""
    (?<DAY>(?:(?<YEARM>(?:16|17|18|19|20|21)\d{2})-\
    (?<MONTH>0[1-9]|10|11|12)-\
    (?<DOM>[0-3]\d))|\
    (?:(?<YEARY>(?:16|17|18|19|20|21)\d{2})-\
    (?<DOY>[0-3]\d\d)))T\
    (?<TIMEOFDAY>(?<HOURS>[01]\d|2[0-4])\
    (?::(?<MINUTES>[0-5]\d)\
    (?::(?<SECONDS>(?:[0-5]\d|60)))?)?\
    (?<SUBSECONDS>.\d{1,9})?)?(?:Z)?\
    """
  end

  def username, do: ~r/^(?:\w+\s){0,31}\w+$/u
  def no_white_space, do: ~r/^\S+$/

  # NUMBERS

  def pos_float, do: ~r/^(?:[1-9]\d*|0)?(?:\.\d+)?$/
  def pos_integer, do: ~r/^[1-9][0-9]*$/
  def non_neg_integer, do: ~r/^[0-9]*$/

  # VERSIONS

  def semver do
    ~r/^([0-9]+)\.([0-9]+)\.([0-9]+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+)?$/
  end

  def patch, do: ~r/^\d*\.?\d*$/

  def region_match_id do
    ~r/(?<region>.+)_(?<match_id>\d+)/
  end
end
