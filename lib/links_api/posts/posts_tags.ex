defmodule LinksApi.Posts.PostsTags do
  use Ecto.Schema

  schema "posts_posts_tags" do
    belongs_to :post, LinksApi.Posts.Post
    belongs_to :tag, LinksApi.Posts.Tag

    timestamps()
  end
end
