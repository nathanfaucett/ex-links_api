defmodule LinksApi.Repo.Migrations.CreateLinksApi.Accounts.User do
  use Ecto.Migration

  def change do
    create table(:accounts_users, primary_key: false) do
      add :id, :integer, primary_key: true
      add :email, :string

      timestamps()
    end

    create unique_index(:accounts_users, [:id])
  end
end
