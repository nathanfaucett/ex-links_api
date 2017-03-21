defmodule LinksApi.Web.UserController do
  use LinksApi.Web, :controller

  alias LinksApi.Repo
  alias LinksApi.Accounts

  alias LinksApi.Web.OAuth2.Github
  alias LinksApi.Web.OAuth2.Google

  action_fallback LinksApi.Web.FallbackController


  def index(conn, %{"provider" => provider}) do
    render(conn, "redirect.json", url: authorize_url!(provider))
  end

  def callback(conn, %{"provider" => provider, "code" => code}) do
    # Exchange an auth code for an access token
    client = get_token!(provider, code)

    # Request the user's data with the access token
    oauth2_user = get_user!(provider, client)

    user = Accounts.get_or_create_user(oauth2_user)
    {:ok, session} = Accounts.create_session(%{
      user_id: user.id,
      token: client.token.access_token
    })

    # Store the user in the session under `:current_user` and redirect to /.
    # In most cases, we'd probably just store the user's ID that can be used
    # to fetch from the database. In this case, since this example app has no
    # database, I'm just storing the user map.
    #
    # If you need to make additional resource requests, you may want to store
    # the access token as well.
    conn
    |> render("user.json", user: user, token: session.token)
  end

  def create_from_token(conn, _params) do
    session = Accounts.get_session_from_conn(conn)

    if session != nil do
      user = Accounts.get_user(session.user_id)

      if user != nil do
        conn
        |> render("user.json", user: user, token: session.token)
      else
        conn
        |> put_status(:unauthorized)
        |> render("error.json")
      end
    else
      conn
      |> put_status(:unauthorized)
      |> render("error.json")
    end
  end

  def delete(conn, _params) do
    session = Accounts.get_session_from_conn(conn)

    if session != nil do
      Repo.delete!(session)
      conn
        |> put_status(:no_content)
        |> json("")
        |> halt
    else
      conn
        |> put_status(:unauthorized)
        |> render("error.json")
    end
  end

  defp authorize_url!("github") do
    Github.authorize_url!(scope: "user,user:email")
  end
  defp authorize_url!("google") do
    Google.authorize_url!(scope: "https://www.googleapis.com/auth/userinfo.email")
  end
  defp authorize_url!(_) do
    raise "No matching provider available"
  end

  defp get_token!("github", code) do
    Github.get_token!(code: code)
  end
  defp get_token!("google", code) do
    Google.get_token!(code: code)
  end
  defp get_token!(_, _) do
    raise "No matching provider available"
  end

  defp get_user!("github", client) do
    %{body: user} = OAuth2.Client.get!(client, "/user")
    %{email: user["email"]}
  end
  defp get_user!("google", client) do
    %OAuth2.Response{body: user} = OAuth2.Client.get!(client, "https://www.googleapis.com/oauth2/v1/userinfo")
    %{email: user["email"]}
  end
end
