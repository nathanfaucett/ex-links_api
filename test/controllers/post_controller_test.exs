defmodule LinksApi.PostControllerTest do
  use LinksApi.ConnCase

  alias LinksApi.Post

  @valid_attrs %{title: "Title", href: "http://www.example.com"}
  @invalid_attrs %{href: "heep:\\\\badhref.com"}

  setup %{conn: conn} do
    user = Repo.insert!(LinksApi.User.registration_changeset(%LinksApi.User{}, %{
      email: "post_test_user@domain.com",
      password: "password",
      confirmed: true,
      confirmation_token: nil
    }))
    subject = Repo.insert!(%LinksApi.Subject{
      name: "Post Test Subject"
    })
    valid_attrs = @valid_attrs
      |> Map.put(:user_id, user.id)
      |> Map.put(:subject_id, subject.id)
      |> Map.put(:tags, ["PostTestTag"])


    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, subject: subject, valid_attrs: valid_attrs}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn, valid_attrs: valid_attrs} do
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
      |> Repo.preload([:user, :subject, :tags])
    conn = get conn, post_path(conn, :show, post)
    assert json_response(conn, 200)["data"] == %{
      "id" => post.id,
      "title" => post.title,
      "href" => post.href,
      "user_id" => post.user.id,
      "subject_id" => post.subject.id,
      "tags" => post.tags}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, post_path(conn, :create), post: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
    conn = put conn, post_path(conn, :update, post), post: valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Post, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, valid_attrs: valid_attrs} do
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, valid_attrs: valid_attrs} do
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
    conn = delete conn, post_path(conn, :delete, post)
    assert response(conn, 204)
    refute Repo.get(Post, post.id)
  end
end
