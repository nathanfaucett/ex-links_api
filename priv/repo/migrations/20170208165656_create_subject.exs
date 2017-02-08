defmodule LinksApi.Repo.Migrations.CreateSubject do
  use Ecto.Migration

  def change do
    create table(:subjects) do
      add :name, :string

      timestamps()
    end

    create unique_index(:subjects, [:name])
  end
end
