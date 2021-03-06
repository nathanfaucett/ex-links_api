defmodule LinksApi.Web.TagView do
  use LinksApi.Web, :view
  alias LinksApi.Web.TagView

  def render("index.json", %{tags: tags}) do
    %{data: render_many(tags, TagView, "tag.json")}
  end

  def render("show.json", %{tag: tag}) do
    %{data: render_one(tag, TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    tag.name
  end
end
