defmodule LinksApi.LinkTest do
  use LinksApi.ModelCase

  alias LinksApi.Link

  @valid_attrs %{href: "https://www.example.com"}
  @invalid_attrs %{href: "invalid url"}

  test "changeset with valid attributes" do
    changeset = Link.changeset(%Link{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Link.changeset(%Link{}, @invalid_attrs)
    refute changeset.valid?
  end
end
