defmodule WagmiPG.Helpers.PhoneNumber do
  @moduledoc "Shared function for validating phone number"

  import Ecto.Changeset

  def validate_changeset(%Ecto.Changeset{} = changeset) do
    changeset
    |> validate_length(:phone_number, max: 25)
    |> validate_phone_number_format()
  end

  defp validate_phone_number_format(changeset) do
    phone_number = get_change(changeset, :phone_number)

    with {:ok, phone_number} <- ExPhoneNumber.parse(phone_number, nil),
         true <- ExPhoneNumber.is_possible_number?(phone_number),
         true <- ExPhoneNumber.is_valid_number?(phone_number) do
      phone_number = ExPhoneNumber.format(phone_number, :e164)
      put_change(changeset, :phone_number, phone_number)
    else
      {:error, message} -> add_error(changeset, :phone_number, message)
      _ -> add_error(changeset, :phone_number, "Not a valid phone number.")
    end
  end
end
