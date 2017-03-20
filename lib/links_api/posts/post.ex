defmodule LinksApi.Posts.Post do
  use Ecto.Schema

  schema "posts_posts" do
    field :href, :string
    field :title, :string

    belongs_to :user, LinksApi.Accounts.User, on_replace: :nilify
    belongs_to :subject, LinksApi.Posts.Subject, on_replace: :nilify
    many_to_many :tags, LinksApi.Posts.Tag, join_through: LinksApi.Posts.PostsTags, on_delete: :nothing
    has_many :stars, LinksApi.Posts.Star, on_delete: :nothing

    timestamps()
  end
end
