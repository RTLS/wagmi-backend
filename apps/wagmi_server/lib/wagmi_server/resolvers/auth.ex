defmodule WagmiServer.Resolvers.Auth do
  @moduledoc "Resolvers for auth queries and mutations."

  require Logger

  alias WagmiPG.{Auth, Helpers}

  @from_phone_number "+13234757281"

  def me(_args, %{context: %{current_user: me}} = _resolution) do
    {:ok, me}
  end

  def me(_, _) do
    {:error, "Not authorized."}
  end

  def update_user(args, %{context: %{current_user: user}}) do
    if args == %{} do
      {:ok, user}
    else
      Auth.update_user(user, args)
    end
  end

  def update_user(_, _) do
    {:error, "Not authorized."}
  end

  def send_security_code(%{phone_number: phone_number}, _resolution) do
    with {:ok, phone_number} <- Helpers.PhoneNumber.validate(phone_number),
         security_code <- Auth.AuthenticationAttempt.generate_security_code(),
         {:ok, _} <-
           Auth.delete_existing_and_create_authentication_attempt(%{
             phone_number: phone_number,
             security_code: security_code
           }),
         {:ok, %ExTwilio.Message{}} <- send_text_message(phone_number, security_code) do
      {:ok, "Security code sent."}
    else
      {:error, error} = res ->
        Logger.error(error)
        res
    end
  end

  def verify_security_code(
        %{phone_number: phone_number, security_code: security_code},
        _resolution
      ) do
    with {:ok, phone_number} <- Helpers.PhoneNumber.validate(phone_number),
         {:ok, auth_attempt} <-
           Auth.find_and_increment_authentication_attempt(%{phone_number: phone_number}),
         :ok <- validate_security_code(auth_attempt, security_code),
         {:ok, _} <- Auth.delete_authentication_attempt(auth_attempt),
         {:ok, user} <- Auth.find_or_create_user(%{phone_number: phone_number}),
         user_session_params <- Auth.UserSession.generate_user_session_params(user.id),
         {:ok, user_session} <- Auth.create_user_session(user_session_params) do
      {:ok, %{user_session | user: user}}
    else
      {:error, error} ->
        Logger.error(error)
        {:error, "Authentication failed."}
    end
  end

  defp validate_security_code(
         %Auth.AuthenticationAttempt{security_code: security_code},
         security_code
       ),
       do: :ok

  defp validate_security_code(_, _), do: {:error, "Invalid security_code."}

  defp send_text_message(to_phone_number, security_code) do
    ExTwilio.Message.create(
      to: to_phone_number,
      from: @from_phone_number,
      body: "Your Wagmi verifcation code is #{security_code}"
    )
  end
end
