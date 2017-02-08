defmodule LinksApi.SubjectTest do
  use LinksApi.ModelCase

  alias LinksApi.Subject

  @valid_attrs %{name: "Valid Subject"}
  @invalid_attrs %{name: "invalid subject"}

  test "changeset with valid attributes" do
    changeset = Subject.changeset(%Subject{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Subject.changeset(%Subject{}, @invalid_attrs)
    refute changeset.valid?
  end
end
