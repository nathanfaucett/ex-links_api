defmodule LinksApi.Subject do
  use LinksApi.Web, :model

  schema "subjects" do
    field :name, :string
    has_many :posts, LinksApi.Post

    timestamps()
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
