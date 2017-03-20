defmodule LinksApi.Web.UserView do
  use LinksApi.Web, :view
  alias LinksApi.Web.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("redirect.json", %{url: url}) do
    %{data: url}
  end

  def render("user.json", %{user: user, token: token}) do
    %{id: user.id,
      email: user.email,
      token: token}
  end
end
