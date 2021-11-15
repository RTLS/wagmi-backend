defmodule SharedUtils.Error do
  @moduledoc """
  This module has error generation functions, each atom passed into
  `error_message_defs` is created to the format of `&error_message/2` and
  `&error_message/3` with the code pre-passed in

  *Note: `error_message_defs` is a gross macro, but I can't think of a
  better way that doesn't involve `n * 7` lines of code for every code*

  ### Example

    error_message_defs(:not_found)

  now we can do

    Error.not_found("Something Happened?", %{error_details: ...})
    Error.not_found("Something Happened?")
  """

  @type t ::
          %{code: atom, message: String.t()}
          | %{code: atom, message: String.t(), details: any}

  @http_error_codes ~w(
    not_found
    bad_request
    expectation_failed
    too_many_requests
    gateway_timeout
    service_unavailable
    bad_gateway
    internal_server_error
    unsupported_media_type
    method_not_allowed
    not_acceptable
    forbidden
    unauthorized
    unprocessable_entity
    not_implemented
    conflict
    failed_dependency
  )a

  for error_code <- @http_error_codes do
    def unquote(error_code)(message) do
      %{code: unquote(error_code), message: message}
    end

    def unquote(error_code)(message, details) do
      %{code: unquote(error_code), message: message, details: details}
    end
  end

  def make_details_inspected(%{details: details} = error) do
    %{error | details: details |> serialize_details |> inspect}
  end

  def make_details_inspected(error), do: error

  def make_error_jsonable(%{details: details} = error) do
    %{error | details: serialize_details(details)}
  end

  def make_error_jsonable(error), do: error

  defp serialize_details(%_{} = details) do
    serialize_details_enum(Map.delete(details, :__struct__))
  end

  defp serialize_details(details) when is_map(details) do
    serialize_details_enum(details)
  end

  defp serialize_details(details) when is_tuple(details) do
    Tuple.to_list(details)
  end

  defp serialize_details(details) when is_list(details) do
    if Keyword.keyword?(details) do
      serialize_details_enum(details)
    else
      Enum.map(details, &serialize_details/1)
    end
  end

  defp serialize_details(details), do: details

  defp serialize_details_enum(details) do
    Enum.reduce(details, %{}, fn
      {_key, value}, acc when is_function(value) -> acc
      {key, value}, acc -> Map.put(acc, key, serialize_details(value))
    end)
  end
end
