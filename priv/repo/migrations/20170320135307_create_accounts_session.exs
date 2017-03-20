defmodule LinksApi.Repo.Migrations.CreateLinksApi.Accounts.Session do
  use Ecto.Migration

  def change do
    create table(:accounts_sessions, primary_key: false) do
      add :token, :string, primary_key: true
      add :user_id, references(:accounts_users, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:accounts_sessions, [:token])
  end
end
