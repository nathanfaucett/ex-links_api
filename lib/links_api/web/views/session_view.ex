defmodule LinksApi.Web.SessionView do
  use LinksApi.Web, :view
  alias LinksApi.Web.SessionView

  def render("index.json", %{sessions: sessions}) do
    %{data: render_many(sessions, SessionView, "session.json")}
  end

  def render("show.json", %{session: session}) do
    %{data: render_one(session, SessionView, "session.json")}
  end

  def render("session.json", %{session: session}) do
    %{id: session.id,
      token: session.token}
  end
end
