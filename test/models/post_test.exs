defmodule LinksApi.PostTest do
  use LinksApi.ModelCase

  alias LinksApi.Post

  @valid_attrs %{title: "Title", href: "http://www.example.com", user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
