defmodule LinksApi.PostControllerTest do
  use LinksApi.ConnCase

  alias LinksApi.Post

  @valid_attrs %{
    title: "Title",
    href: "http://www.example.com",
    subject: "PostControllerTestSubject",
    tags: ["PostControllerTestTag"]}

  @invalid_attrs %{
    href: "heep:\\\\badhref.com",
    subject: "PostControllerTestSubject",
    tags: ["PostControllerTestTag"]}

  @user_attrs %{
    email: "post_controller_test_user@domain.com",
    password: "password",
    confirmed: true,
    confirmation_token: nil}

  setup %{conn: conn} do
    user = Repo.insert!(LinksApi.User.registration_changeset(%LinksApi.User{}, @user_attrs))
    valid_attrs = @valid_attrs
      |> Map.put(:user_id, user.id)

    create_conn = post conn, session_path(conn, :create), user: @user_attrs
    session = create_conn.assigns[:session]

    conn = conn
      |> assign(:current_user, user)
      |> put_req_header("accept", "application/json")
      |> put_req_header("x-links-user.token", session.token)

    {:ok, conn: conn, user: user, valid_attrs: valid_attrs}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index, %{"page_size" => 20, "offset" => 0})
    assert json_response(conn, 200)["data"] == []
  end

  test "lists all entries matching subject or tags", %{conn: conn} do
    conn = get conn, post_path(conn, :index, %{
      "subject" => "PostControllerTestSubject",
      "tags" => ["PostControllerTestTag"]})
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
      "subject" => post.subject.name,
      "tags" => Enum.map(post.tags, fn(tag) -> tag.name end)}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    conn = post conn, post_path(conn, :create), post: valid_attrs
    id = json_response(conn, 201)["data"]["id"]
    assert id
    assert Repo.get(Post, id)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, valid_attrs: valid_attrs} do
    post = Repo.insert!(Post.changeset(%Post{}, valid_attrs))
    conn = put conn, post_path(conn, :update, post), post: valid_attrs
    id = json_response(conn, 200)["data"]["id"]
    assert id
    assert Repo.get(Post, id)
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
