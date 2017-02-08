defmodule LinksApi.Link do
  use LinksApi.Web, :model

  schema "links" do
    field :href, :string
    has_many :posts, LinksApi.Post

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:href])
    |> validate_url(:href)
    |> validate_required([:href])
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
