defmodule LinksApi.Repo.Migrations.CreateLinksApi.Posts.Subject do
  use Ecto.Migration

  def change do
    create table(:posts_subjects) do
      add :name, :string

      timestamps()
    end

    create unique_index(:posts_subjects, [:name])
  end
end
