defmodule LinksApi.Repo.Migrations.CreatePostsTags do
  use Ecto.Migration

  def change do
    create table(:posts_tags, primary_key: false) do
      add :post_id, references(:posts, on_delete: :nothing)
      add :tag_id, references(:tags, on_delete: :nothing)
    end

    create index(:posts_tags, [:post_id])
    create index(:posts_tags, [:tag_id])
  end
end
