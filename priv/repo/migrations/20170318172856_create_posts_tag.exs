defmodule LinksApi.Repo.Migrations.CreateLinksApi.Posts.Tag do
  use Ecto.Migration

  def change do
    create table(:posts_tags) do
      add :name, :string

      timestamps()
    end

    create unique_index(:posts_tags, [:name])
  end
end
