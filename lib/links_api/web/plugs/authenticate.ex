defmodule LinksApi.Web.Plugs.Authenticate do
  use Phoenix.Controller

  alias LinksApi.Accounts


  def init(default), do: default

  def call(conn, _default) do
    session = Accounts.get_session_from_conn(conn)

    if session != nil do
      current_user = Accounts.get_user(session.user_id)
      assign(conn, :current_user, current_user)
    else
      conn
        |> put_status(:unauthorized)
        |> put_view(LinksApi.Web.ErrorView)
        |> render("401.json")
        |> halt
    end
  end
end
