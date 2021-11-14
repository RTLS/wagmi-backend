defmodule WagmiPG.Repo.Migrations.AddUsernameToUser do
  use Ecto.Migration

  def change do
    alter table(:user) do
      add :username, :text
    end

    create unique_index(:user, :username, where: "username IS NOT NULL")
  end
end
