defmodule LinksApi.TagTest do
  use LinksApi.ModelCase

  alias LinksApi.Tag

  @valid_attrs %{name: "Some"}
  @invalid_attrs %{name: "Invalid tag"}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
