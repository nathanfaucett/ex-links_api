defmodule LinksApi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false

      add :confirmed, :boolean, default: false
      add :confirmation_token, :string

      add :password_hash, :string

      timestamps()
    end
    create unique_index(:users, [:email])
  end
end
