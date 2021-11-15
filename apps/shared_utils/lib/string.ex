defmodule SharedUtils.String do
  @moduledoc """
  Module for string related helpers
  """

  @log_prefix "SharedUtils.String"

  @doc """
  Removes spaces from a string

  Examples

    iex> SharedUtils.String.remove_spaces("I am a test string")
    "Iamateststring"
    iex> SharedUtils.String.remove_spaces("I am a test string", "-")
    "I-am-a-test-string"
  """
  @spec remove_spaces(String.t()) :: String.t()
  @spec remove_spaces(String.t(), String.t()) :: String.t()
  def remove_spaces(string, replacer \\ ""), do: String.replace(string, " ", replacer)

  @doc """
  Checks if an email of valid format

  Examples

      iex> SharedUtils.String.valid_email?("ab.ca")
      false
      iex> SharedUtils.String.valid_email?("a@b.ca")
      true
  """
  @spec valid_email?(String.t()) :: boolean
  def valid_email?(string), do: string =~ ~r/.+@.+\..+/

  @doc """
  Checks if an email of valid format

  Examples

      iex> SharedUtils.String.check_valid_email("a@b.ca")
      :ok
      iex> SharedUtils.String.check_valid_email("ab.ca")
      {:error, %{code: :bad_request, message: "email is invalid", details: %{email: "ab.ca"}}}
  """
  @spec check_valid_email(String.t()) :: :ok | {:error, SharedUtils.Error.t()}
  def check_valid_email(email) do
    if SharedUtils.String.valid_email?(email) do
      :ok
    else
      {:error, SharedUtils.Error.bad_request("email is invalid", %{email: email})}
    end
  end

  @doc """
  Converts a string to lower kebab case

  Examples

      iex> SharedUtils.String.to_lower_kebab_case("Hello Test")
      "hello-test"
      iex> SharedUtils.String.to_lower_kebab_case("I'm a security code")
      "im-a-security-code"
      iex> SharedUtils.String.to_lower_kebab_case("I_get-substituted")
      "i-get-substituted"
  """
  @spec to_lower_kebab_case(String.t()) :: String.t()
  def to_lower_kebab_case(string) do
    string
    |> String.replace(~r/[^a-z -_]/i, "")
    |> String.replace("'", "")
    |> String.replace(~r/[_ ]/, "-")
    |> String.downcase()
  end

  @doc """
  Converts a string to boolean.

    iex> SharedUtils.String.to_bool("true")
    true
    iex> SharedUtils.String.to_bool("false")
    false
    iex> SharedUtils.String.to_bool("something")
    false
  """
  @spec to_bool(String.t()) :: boolean
  def to_bool(string) do
    case string do
      "false" -> false
      "true" -> true
      _ -> false
    end
  end

  @doc """
  Converts string to integer or float.

  iex> SharedUtils.String.to_number("1")
  1

  iex> SharedUtils.String.to_number("1.1")
  1.1

  iex> SharedUtils.String.to_number(nil)
  {:error, %{code: :bad_request, message: "Cannot parse number: nil"}}
  """
  def to_number(value) when is_binary(value) do
    case {Integer.parse(value), Float.parse(value)} do
      {{integer, ""}, {_float, _remainder}} -> integer
      {{_integer, _remainder}, {float, ""}} -> float
      _ -> cannot_parse_error(value)
    end
  end

  def to_number(value), do: cannot_parse_error(value)

  @spec generate_random(pos_integer) :: binary
  def generate_random(bytes) do
    Base.encode32(:crypto.strong_rand_bytes(bytes), padding: false)
  end

  defp cannot_parse_error(value) do
    SharedUtils.Logger.error(@log_prefix, "Cannot parse number: #{inspect(value)}")
    {:error, SharedUtils.Error.bad_request("Cannot parse number: #{inspect(value)}")}
  end

  @spec empty?(String.t()) :: boolean
  @doc """
  Checks if a string is empty and returns a boolean

  ## Example

    iex> SharedUtils.String.empty?(" ")
    true

    iex> SharedUtils.String.empty?("")
    true

    iex> SharedUtils.String.empty?("content")
    false

  """
  def empty?(str), do: str |> String.trim() |> Kernel.===("")

  @spec check_not_empty(String.t()) :: :ok | {:error, SharedUtils.Error.t()}
  @spec check_not_empty(String.t(), String.t()) :: :ok | {:error, SharedUtils.Error.t()}
  @doc """
  Checks if a string is empty and returns an ok error tuple

  ## Example

    iex> SharedUtils.String.check_not_empty(" ")
    {:error, %{code: :bad_request, message: "cannot be an empty string"}}

    iex> SharedUtils.String.check_not_empty("")
    {:error, %{code: :bad_request, message: "cannot be an empty string"}}

    iex> SharedUtils.String.check_not_empty(nil)
    :ok

    iex> SharedUtils.String.check_not_empty("content")
    :ok
  """
  def check_not_empty(str, message \\ "cannot be an empty string")

  def check_not_empty(nil, _message) do
    :ok
  end

  def check_not_empty(str, message) do
    if empty?(str) do
      {:error, SharedUtils.Error.bad_request(message)}
    else
      :ok
    end
  end
end
