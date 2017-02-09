defmodule LinksApi.Post do
  use LinksApi.Web, :model

  schema "posts" do
    field :title, :string
    field :href, :string

    belongs_to :user, LinksApi.User
    belongs_to :subject, LinksApi.Subject
    many_to_many :tags, LinksApi.Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :href])
    |> validate_url(:href)
    |> validate_required([:title, :href])
  end


  def validate_url(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, url) ->
      case url |> String.to_char_list |> :http_uri.parse do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || "invalid url: #{inspect msg}"}]
      end
    end)
  end
end
