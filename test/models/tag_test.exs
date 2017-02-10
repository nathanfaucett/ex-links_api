defmodule LinksApi.TagTest do
  use LinksApi.ModelCase

  alias LinksApi.Tag

  @valid_attrs %{name: "Some"}
  @invalid_attrs %{name: "Invalid tag"}
  @valid_tags ["TestTag0", "TestTag1", "TestTag2", "TestTag3"]

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "return list of tags from list of strings" do
    valid_tags = @valid_tags
    tags = Tag.get_tags(valid_tags)
    Enum.map(tags, fn(tag) ->
      assert Enum.member?(valid_tags, tag.name)
      Repo.delete!(tag)
    end)
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
