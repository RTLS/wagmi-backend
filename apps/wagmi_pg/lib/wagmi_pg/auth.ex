defmodule WagmiPG.Auth do
  @moduledoc "Context for users and user authentication."

  alias WagmiPG.Auth.{AuthenticationAttempt, User, UserSession}
  alias EctoShorts.{Actions, CommonFilters}

  def find_user(params) do
    Actions.find(User, params)
  end

  def create_user(params) do
    Actions.create(User, params)
  end

  def update_user(user, params) do
    Actions.update(User, user, params)
  end

  def find_or_create_user(params) do
    Actions.find_or_create(User, params)
  end

  def create_user_session(params) do
    Actions.create(UserSession, params)
  end

  def find_user_session(params) do
    Actions.find(UserSession, params)
  end

  def delete_all_user_sessions(params) do
    query = CommonFilters.convert_params_to_filter(UserSession, params, nil)
    WagmiPG.Repo.delete_all(query)
  end

  def create_authentication_attempt(params) do
    Actions.create(AuthenticationAttempt, params)
  end

  def update_authentication_attempt(find_params, update_params) do
    Actions.update(AuthenticationAttempt, find_params, update_params)
  end

  def find_authentication_attempt(params) do
    Actions.find(AuthenticationAttempt, params)
  end

  def find_and_increment_authentication_attempt(params) do
    params = Map.merge(AuthenticationAttempt.default_find_params(), params)

    WagmiPG.Repo.transaction(fn ->
      with {:ok, %{attempts: attempts} = auth_attempt} <- find_authentication_attempt(params) do
        {:ok, auth_attempt} = update_authentication_attempt(auth_attempt, %{attempts: attempts + 1})
         auth_attempt
       end
    end)
  end

  def delete_authentication_attempt(%AuthenticationAttempt{} = authentication_attempt) do
    Actions.delete(authentication_attempt)
  end

  def delete_all_authentication_attempts(params) do
    query = CommonFilters.convert_params_to_filter(AuthenticationAttempt, params, nil)
    WagmiPG.Repo.delete_all(query)
  end

  def delete_existing_and_create_authentication_attempt(%{phone_number: phone_number} = params) do
    WagmiPG.Repo.transaction(fn ->
      {_count, nil} = delete_all_authentication_attempts(%{phone_number: phone_number})
      {:ok, _} = create_authentication_attempt(params)
    end)
  end
end
