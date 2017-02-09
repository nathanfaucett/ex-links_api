defmodule LinksApi.PostView do
  use LinksApi.Web, :view

  def render("index.json", %{post: post}) do
    %{data: render_many(post, LinksApi.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, LinksApi.PostView, "post.json")}
  end

  def render("post.json", %{post: post}) do
    %{id: post.id,
      title: post.title,
      href: post.href,
      user_id: post.user_id,
      subject_id: post.subject_id,
      tags: post.tags}
  end
end
