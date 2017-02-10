defmodule LinksApi.Tag do
  use LinksApi.Web, :model

  schema "tags" do
    field :name, :string
    many_to_many :posts, LinksApi.Post, join_through: "posts_tags"

    timestamps()
  end

  def create_if_not_exists(name) do
    query = from(t in LinksApi.Tag,
          where: t.name == ^name)
    tag = LinksApi.Repo.one(query)

    if tag == nil do
      LinksApi.Repo.insert(LinksApi.Tag
        .changeset(%LinksApi.Tag { name: name }))
    else
      {:ok, tag}
    end
  end

  def get_tags(tags \\ []) do
    Enum.filter_map(
      tags,
      fn(tag) -> tag != nil end,
      fn(tag) ->
        case create_if_not_exists(tag) do
          {:ok, tag} -> tag
          {:err, _} -> nil
        end
      end
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
      |> cast(params, [:name])
      |> validate_tag(:name)
      |> validate_required([:name])
  end


  def validate_tag(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, tag) ->
      case !Regex.match?(~r/[\s ]+/, tag) && tag == LinksApi.Util.camelcase(tag) do
        true -> []
        false -> [{field, options[:message] || "invalid tag must be lower case with no spaces"}]
      end
    end)
  end
end
