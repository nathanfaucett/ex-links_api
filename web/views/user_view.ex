defmodule LinksApi.UserView do
  use LinksApi.Web, :view

  def render("show.json", %{session: session, user: user}) do
    %{user: %{
      id: user.id,
      email: user.email,
      confirmed: user.confirmed,
      token: session.token
    }}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id, email: user.email}
  end

  def render("error.json", _anything) do
    %{errors: "Failed to authenticate"}
  end
end
