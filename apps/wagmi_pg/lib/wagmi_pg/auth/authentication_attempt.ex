defmodule WagmiPG.Auth.AuthenticationAttempt do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias WagmiPG.Helpers

  schema "authentication_attempt" do
    field :phone_number, :string
    field :security_code, :string
    field :attempts, :integer

    timestamps()
  end

  @required_params [:phone_number, :security_code]
  @all_params [:attempts | @required_params]
  @security_token_length 6
  @valid_for :timer.minutes(3)
  @max_attempts 3

  def create_changeset(params), do: changeset(%AuthenticationAttempt{}, params)

  def changeset(%AuthenticationAttempt{} = user, params) do
    user
    |> cast(params, @all_params)
    |> validate_required(@required_params)
    |> Helpers.PhoneNumber.validate_changeset()
    |> unique_constraint(:phone_number)
  end

  def generate_security_code do
    1..@security_token_length
    |> Enum.map(fn _ -> :rand.uniform(10) - 1 end)
    |> Enum.join("")
  end

  def default_find_params do
    %{
      attempts: %{lt: @max_attempts},
      inserted_at: %{gt: DateTime.add(DateTime.utc_now(), -@valid_for, :millisecond)}
    }
  end
end
