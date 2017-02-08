defmodule LinksApi.PostTest do
  use LinksApi.ModelCase

  alias LinksApi.Post

  @valid_attrs %{title: "Title", user_id: 1, link_id: 1, subject_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    tag = LinksApi.Repo.get!(LinksApi.Tag, 1)
    changeset = Post.changeset(%Post{}, @valid_attrs)
      |> put_assoc(:tags, [tag])

    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
