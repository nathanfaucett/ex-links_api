defmodule LinksApi.Posts.Subject do
  use Ecto.Schema

  schema "posts_subjects" do
    field :name, :string
    has_many :posts, LinksApi.Posts.Post, on_delete: :nothing

    timestamps()
  end
end
