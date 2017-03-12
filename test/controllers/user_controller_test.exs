
defmodule LinksApi.UserControllerTest do
  use LinksApi.ConnCase

  alias LinksApi.User
  @valid_attrs %{email: "foo@bar.com", password: "s3cr3t"}
  @valid_confirmation_attrs %{email: "bar@foo.com", password: "s3cr3t"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    changeset =  User.registration_changeset(%User{}, @valid_confirmation_attrs)
    Repo.insert changeset
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @valid_attrs
    body = json_response(conn, 201)
    assert body["user"]["id"]
    assert body["user"]["email"]
    assert !body["user"]["confirmed"]
    refute body["user"]["password"]
    assert Repo.get_by(User, email: "foo@bar.com")
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "should confirm user based on token email", %{conn: conn} do
    create_conn = post conn, session_path(conn, :create), user: @valid_confirmation_attrs

    session = create_conn.assigns[:session]
    user = Repo.get_by!(User, id: session.user_id)
    conn = put_req_header(conn, "x-links-user_token", session.token)

    conn = post conn, user_path(conn, :confirm, user.confirmation_token), %{}
    assert json_response(conn, 204)

    confirmed_user = Repo.get_by!(User, id: user.id)
    assert confirmed_user.confirmed == true
    assert confirmed_user.confirmation_token == nil
  end

  test "resends confirmation token email", %{conn: conn} do
    create_conn = post conn, session_path(conn, :create), user: @valid_confirmation_attrs

    session = create_conn.assigns[:session]
    conn = put_req_header(conn, "x-links-user_token", session.token)

    conn = post conn, user_path(conn, :resend_confirmation_token), %{}
    assert json_response(conn, 204)
  end
end
