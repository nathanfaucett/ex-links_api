defmodule LinksApi.PostsTags do
  use LinksApi.Web, :model

  schema "posts_tags" do
    belongs_to :post, LinksApi.Post
    belongs_to :tag, LinksApi.Tag

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [])
  end
end
