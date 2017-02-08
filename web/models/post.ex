defmodule LinksApi.Post do
  use LinksApi.Web, :model

  schema "posts" do
    field :title, :string

    belongs_to :user, LinksApi.User

    has_one :link, LinksApi.Link
    has_one :subject, LinksApi.Subject
    
    many_to_many :tags, LinksApi.Tag, join_through: "posts_tags"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :user_id, :link_id, :subject_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:link_id)
    |> foreign_key_constraint(:subject_id)
    |> validate_required([:title, :user_id, :link_id, :subject_id])
  end
end
