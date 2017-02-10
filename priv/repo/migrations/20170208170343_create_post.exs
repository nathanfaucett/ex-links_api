defmodule LinksApi.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :href, :string

      add :user_id, references(:users, on_delete: :nothing)
      add :subject_id, references(:subjects, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:posts, [:href])
    create index(:posts, [:user_id])
    create index(:posts, [:subject_id])
  end
end
