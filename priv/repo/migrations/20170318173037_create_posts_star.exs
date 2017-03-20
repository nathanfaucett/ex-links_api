defmodule LinksApi.Repo.Migrations.CreateLinksApi.Posts.Star do
  use Ecto.Migration

  def change do
    create table(:posts_stars) do
      add :user_id, references(:accounts_users, on_delete: :nothing)
      add :post_id, references(:posts_posts, on_delete: :nothing)

      timestamps()
    end

  end
end
