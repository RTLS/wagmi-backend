defmodule SharedUtils.IpParser do
  @doc """
  Parse raw ip into a string

  ## Example

    iex> SharedUtils.IpParser.parse({192, 168, 1, 0})
    "192.168.1.0"

  """
  @spec parse(tuple) :: String.t()
  def parse(raw_ip) do
    raw_ip |> :inet.ntoa() |> List.to_string()
  end

  @doc """
  Parse ip from x-forwarded-for

  ## Example

    iex> SharedUtils.IpParser.parse_forwarded_for("192.168.1.0, 162.158.148.195, 34.98.118.172")
    "192.168.1.0"

  """
  @spec parse_forwarded_for(String.t()) :: String.t()
  def parse_forwarded_for(forwarded_for_string) do
    forwarded_for_string |> String.split(", ") |> hd
  end
end
