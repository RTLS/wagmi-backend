defmodule WagmiPG.Repo.Migrations.CreateUserAndAuthenticationAttemptAndUserSession do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :phone_number, :text, null: false

      timestamps()
    end

    create unique_index(:user, :phone_number)

    create table(:authentication_attempt) do
      add :phone_number, :text, null: false
      add :security_code, :text, null: false
      add :attempts, :smallint, null: false, default: 0

      timestamps()
    end

    create unique_index(:authentication_attempt, :phone_number)

    create table(:user_session) do
      add :hashed_token, :text
      add :user_id, references(:user, type: :binary_id), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:user_session, :hashed_token)
    create index(:user_session, :user_id)
  end
end
