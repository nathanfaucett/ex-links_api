defmodule LinksApi.PostTest do
  use LinksApi.ModelCase

  alias LinksApi.Post

  @valid_attrs %{
    title: "Title",
    href: "http://www.example.com",
    subject: "PostTestSubject",
    tags: ["PostTestTag"]}
  @invalid_attrs %{subject: "invalid_subject", tags: []}

  @user_attrs %{
    email: "post_test_user@domain.com",
    password: "password",
    confirmed: true,
    confirmation_token: nil
  }


  setup do
    user = Repo.insert!(LinksApi.User.registration_changeset(%LinksApi.User{}, @user_attrs))
    valid_attrs = @valid_attrs
      |> Map.put(:user_id, user.id)

    {:ok, valid_attrs: valid_attrs}
  end

  test "changeset with valid attributes", %{valid_attrs: valid_attrs} do
    changeset = Post.changeset(%Post{}, valid_attrs)
    assert changeset.valid?
  end

  test "insert with valid attributes", %{valid_attrs: valid_attrs} do
    valid_attrs = valid_attrs
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
      |> Repo.preload([:user, :subject, :tags])

    assert valid_attrs.title == post.title
    assert valid_attrs.href == post.href
    assert valid_attrs.user_id == post.user.id
    assert valid_attrs.subject == post.subject.name
    assert valid_attrs.tags == Enum.map(post.tags, fn(tag) -> tag.name end)
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
