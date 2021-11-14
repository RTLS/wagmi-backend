defmodule WagmiServer.Resolvers.Auth do
  @moduledoc "Resolvers for auth queries and mutations."

  alias WagmiPG.{Auth, Helpers}

  def me(_args, %{context: %{current_user: me}} = _resolution) do
    {:ok, me}
  end

  def me(_, _) do
    {:error, "Not authorized."}
  end

  def send_security_code(%{phone_number: phone_number}, _resolution) do
    with {:ok, phone_number} <- Helpers.PhoneNumber.validate(phone_number),
         security_code <- Auth.AuthenticationAttempt.generate_security_code(),
         {:ok, _} <- Auth.delete_existing_and_create_authentication_attempt(%{phone_number: phone_number, security_code: security_code}) do
      IO.inspect(security_code, label: "Sent security_code via SMS")
      {:ok, "Security code sent to #{phone_number}"}
    end
  end

  def verify_security_code(
        %{phone_number: phone_number, security_code: security_code},
        _resolution
      ) do
    with {:ok, phone_number} <- Helpers.PhoneNumber.validate(phone_number),
         {:ok, auth_attempt} <- Auth.find_and_increment_authentication_attempt(%{phone_number: phone_number}),
         :ok <- validate_security_code(auth_attempt, security_code),
         {:ok, _} <- Auth.delete_authentication_attempt(auth_attempt),
         {:ok, user} <- Auth.find_or_create_user(%{phone_number: phone_number}),
         user_session_params <- Auth.UserSession.generate_user_session_params(user.id),
         {:ok, user_session} <- Auth.create_user_session(user_session_params) do
      {:ok, %{user_session | user: user}}
    else
      _ -> {:error, "Authentication failed."}
    end
  end

  defp validate_security_code(%Auth.AuthenticationAttempt{security_code: security_code}, security_code), do: :ok
  defp validate_security_code(auth_attempt, security_code), do: {:error, "Invalid security_code.\n#{inspect auth_attempt}\n#{security_code}"}
end
