defmodule LinksApi.TagView do
  use LinksApi.Web, :view

  def render("tag.json", %{tag: tag}) do
    tag.name
  end
end
