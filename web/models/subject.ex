defmodule LinksApi.Subject do
  use LinksApi.Web, :model

  schema "subjects" do
    field :name, :string
    has_many :posts, LinksApi.Post, on_delete: :nothing

    timestamps()
  end

  def create_if_not_exists(name) do
    query = from(t in LinksApi.Subject,
          where: t.name == ^name)
    subject = LinksApi.Repo.one(query)

    if subject == nil do
      LinksApi.Repo.insert(LinksApi.Subject
        .changeset(%LinksApi.Subject { name: name }))
    else
      {:ok, subject}
    end
  end

  def get_subject(subject \\ "All") do
    case create_if_not_exists(subject) do
      {:ok, subject} -> subject
      {:err, _} -> nil
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_subject(:name)
    |> validate_required([:name])
  end


  def validate_subject(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, subject) ->
      words = Regex.split(~r/[\s ]+/, subject)
      camel_cased = Enum.map(words, fn(word) ->
        LinksApi.Util.camelcase(word)
      end)

      case Enum.join(camel_cased, " ") == subject do
        true -> []
        false -> [{field, options[:message] || "invalid subject must be camel case words seperated with spaces"}]
      end
    end)
  end
end
