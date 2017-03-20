defmodule LinksApi.Web.PostView do
  use LinksApi.Web, :view
  alias LinksApi.Web.PostView

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{id: post.id,
      title: post.title,
      href: post.href,
      subject: post.subject.name,
      tags: render_many(post.tags, LinksApi.Web.TagView, "tag.json"),
      stars: length(post.stars)}
  end
end
