defmodule LinksApi.Repo.Migrations.CreateLink do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :href, :string

      timestamps()
    end

    create unique_index(:links, [:href])
  end
end
