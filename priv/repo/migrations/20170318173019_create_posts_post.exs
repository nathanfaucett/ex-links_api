defmodule LinksApi.Repo.Migrations.CreateLinksApi.Posts.Post do
  use Ecto.Migration

  def change do
    create table(:posts_posts) do
      add :title, :string
      add :href, :string

      add :user_id, references(:accounts_users, on_delete: :nothing)
      add :subject_id, references(:posts_subjects, on_delete: :nothing)

      timestamps()
    end
  end
end
