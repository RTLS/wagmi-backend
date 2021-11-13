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

  def create_user_session(params) do
    Actions.create(UserSession, params)
  end

  def create_authentication_attempt(params) do
    Actions.create(AuthenticationAttempt, params)
  end

  def find_authentication_attempt(params) do
    Actions.find(AuthenticationAttempt, params)
  end

  def delete_authentication_attempt(%AuthenticationAttempt{} = authentication_attempt) do
    Actions.delete(authentication_attempt)
  end

  def delete_all_authentication_attempts(params) do
    query = CommonFilters.convert_params_to_filter(AuthenticationAttempt, params)
    WagmiPG.Repo.delete_all(query)
  end
end
