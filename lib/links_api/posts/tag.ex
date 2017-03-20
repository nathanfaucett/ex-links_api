defmodule LinksApi.Posts.Tag do
  use Ecto.Schema

  schema "posts_tags" do
    field :name, :string
    many_to_many :posts, LinksApi.Posts.Post, join_through: LinksApi.Posts.PostsTags, on_delete: :nothing

    timestamps()
  end
end
