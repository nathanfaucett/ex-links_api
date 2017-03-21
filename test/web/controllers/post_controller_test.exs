defmodule LinksApi.Web.PostControllerTest do
  use LinksApi.Web.ConnCase

  alias LinksApi.Accounts
  alias LinksApi.Posts
  alias LinksApi.Posts.Post

  @create_user_attrs %{email: "example@domain.com"}
  @create_attrs %{title: "some title", href: "http://www.example.com"}
  @update_attrs %{title: "some updated title", href: "http://www.example.com/updated"}
  @invalid_attrs %{title: nil, href: nil}


  def fixture(:post, attrs) do
    {:ok, post} = Posts.create_post(Map.merge(@create_attrs, attrs))
    post
  end

  def put_session(conn, user) do
    {:ok, session} = Accounts.create_session(%{
      user_id: user.id,
      token: "token-" <> Integer.to_string(user.id)
    })
    put_req_header(conn, "x-links-user-token", session.token)
  end

  setup %{conn: conn} do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, post_path(conn, :index, %{"page_size" => 20, "offset" => 0, "order_by_stars" => true})
    assert json_response(conn, 200)["data"] == []
  end

  test "creates post and renders post when data is valid", %{conn: conn, user: user} do
    conn = put_session(conn, user)

    conn = post conn, post_path(conn, :create), post: @create_attrs
    assert %{"id" => id} = json_response(conn, 201)["data"]

    conn = get conn, post_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "title" => "some title",
      "href" => "http://www.example.com",
      "stars" => 0,
      "subject" => "Any",
      "tags" => []}
  end

  test "does not create post and renders errors when data is invalid", %{conn: conn, user: user} do
    conn = put_session(conn, user)
    conn = post conn, post_path(conn, :create), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates chosen post and renders post when data is valid", %{conn: conn, user: user} do
    %Post{id: id} = post = fixture(:post, %{user_id: user.id})

    conn = put_session(conn, user)
    conn = put conn, post_path(conn, :update, post), post: @update_attrs
    assert %{"id" => ^id} = json_response(conn, 200)["data"]

    conn = get conn, post_path(conn, :show, id)
    assert json_response(conn, 200)["data"] == %{
      "id" => id,
      "title" => "some updated title",
      "href" => "http://www.example.com/updated",
      "stars" => 0,
      "subject" => "Any",
      "tags" => []}
  end

  test "does not update chosen post and renders errors when data is invalid", %{conn: conn, user: user} do
    post = fixture(:post, %{user_id: user.id})
    conn = put_session(conn, user)
    conn = put conn, post_path(conn, :update, post), post: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "stars posts and renders post", %{conn: conn, user: user} do
    post = fixture(:post, %{user_id: user.id})
    conn = assign(conn, :current_user, user)
    conn = put_session(conn, user)
    conn = post conn, post_path(conn, :star, post)
    stars = json_response(conn, 200)["data"]["stars"]
    assert stars == 1
  end

  test "deletes chosen post", %{conn: conn, user: user} do
    post = fixture(:post, %{user_id: user.id})
    conn = put_session(conn, user)
    conn = delete conn, post_path(conn, :delete, post)
    assert response(conn, 204)
    assert_error_sent 404, fn ->
      get conn, post_path(conn, :show, post)
    end
  end
end
