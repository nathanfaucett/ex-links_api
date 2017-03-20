defmodule LinksApi.Posts.Star do
  use Ecto.Schema

  schema "posts_stars" do
    belongs_to :post, LinksApi.Posts.Post
    belongs_to :user, LinksApi.Accounts.User

    timestamps()
  end
end
