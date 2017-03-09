defmodule LinksApi.Star do
  use LinksApi.Web, :model

  schema "stars" do
    belongs_to :post, LinksApi.Post
    belongs_to :user, LinksApi.User

    timestamps()
  end

  def star(post_id, user_id) do
    query = from s in LinksApi.Star,
          where: s.user_id == ^user_id and s.post_id == ^post_id
    star = LinksApi.Repo.one(query)

    if star == nil do
      LinksApi.Repo.insert(LinksApi.Star.changeset(%LinksApi.Star {
        post_id: post_id,
        user_id: user_id
      }))
    else
      LinksApi.Repo.delete(star)
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [])
  end
end
