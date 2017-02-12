defmodule LinksApi.Post do
  use LinksApi.Web, :model

  schema "posts" do
    field :title, :string
    field :href, :string

    belongs_to :user, LinksApi.User, on_replace: :nilify
    belongs_to :subject, LinksApi.Subject, on_replace: :nilify
    many_to_many :tags, LinksApi.Tag, join_through: LinksApi.PostsTags, on_delete: :nothing

    timestamps()
  end

  def put_tags(struct, params) do
    tags = Map.get(params, :tags, Map.get(params, "tags", []))

    if Enum.empty?(tags) do
      struct
    else
      put_assoc(struct, :tags, LinksApi.Tag.get_tags(tags))
    end
  end

  def put_subject(struct, params) do
    subject = String.strip Map.get(params, :subject, Map.get(params, "subject", "All"))
    subject = if subject == "" do
      "All"
    else
      subject
    end
    
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
      |> unique_constraint(:href)
      |> validate_required([:title, :user_id, :href])
      |> put_tags(params)
      |> put_subject(params)
      |> foreign_key_constraint(:subject)
      |> foreign_key_constraint(:tags)
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
