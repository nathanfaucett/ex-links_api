defmodule LinksApi.Repo.Migrations.CreateStar do
  use Ecto.Migration

  def change do
    create table(:stars) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end
  end
end
