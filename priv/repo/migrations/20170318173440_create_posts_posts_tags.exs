defmodule LinksApi.Repo.Migrations.CreateLinksApi.Posts.PostsTags do
  use Ecto.Migration

  def change do
    create table(:posts_posts_tags) do
      add :post_id, references(:posts_posts, on_delete: :nothing)
      add :tag_id, references(:posts_tags, on_delete: :nothing)

      timestamps()
    end

    create index(:posts_posts_tags, [:post_id])
    create index(:posts_posts_tags, [:tag_id])
  end
end
