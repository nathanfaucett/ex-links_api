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

  def put_tags(struct, tags \\ []) do
    if Enum.empty?(tags) do
      put_assoc(struct, :tags, LinksApi.Tag.get_tags(tags))
    else
      struct
    end
  end

  def put_subject(struct, subject \\ "All") do
    put_assoc(struct, :subject, LinksApi.Subject.get_subject(subject))
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :user_id, :href])
    |> foreign_key_constraint(:user_id)
    |> validate_url(:href)
    |> validate_required([:title, :user_id, :href])
    |> put_tags(Map.get(params, :tags, []))
    |> put_subject(Map.get(params, :subject, "All"))
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
