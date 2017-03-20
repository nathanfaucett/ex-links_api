defmodule LinksApi.Web.PostController do
  use LinksApi.Web, :controller

  import Ecto.Query, only: [from: 2]

  alias LinksApi.Repo
  alias LinksApi.Posts
  alias LinksApi.Posts.Post
  alias LinksApi.Posts.Star
  alias LinksApi.Posts.Tag
  alias LinksApi.Posts.Subject
  alias LinksApi.Posts.PostsTags

  action_fallback LinksApi.Web.FallbackController

  plug LinksApi.Web.Plugs.Authenticate when action in
    [:create, :update, :delete, :star]

  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "order_by_stars" => "true"
  }) do
    posts = Posts.all_posts(
      from p in Post,
        limit: ^page_size,
        offset: ^offset,
        left_join: star in assoc(p, :stars),
        order_by: [desc: count(star.id), desc: p.inserted_at],
        group_by: p.id,
        select: p
    )
    render(conn, "index.json", posts: posts)
  end

  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "order_by_stars" => "false"
  }) do
    posts = Posts.all_posts(
      from(p in Post,
        limit: ^page_size,
        offset: ^offset,
        order_by: [desc: p.inserted_at]
      )
    )
    render(conn, "index.json", posts: posts)
  end

  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "subject" => subject
  }) do
    search(conn, %{
      "page_size" => page_size,
      "offset" => offset,
      "subject" => subject,
      "tags" => %{}
    })
  end
  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "subject" => subject,
    "tags" => tags
  }) do
    search(conn, %{
      "page_size" => page_size,
      "offset" => offset,
      "subject" => subject,
      "tags" => tags
    })
  end

  defp search(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "subject" => subject,
    "tags" => tags
  }) do
    subject = Repo.get_by(Subject, name: subject)
    tags = Map.values(tags)

    tag_ids = Repo.all(from t in Tag,
      where: t.name in ^tags,
      select: t.id)

    posts_tags_ids = Repo.all(from pt in PostsTags,
      where: pt.tag_id in ^tag_ids,
      select: pt.post_id)

    post = Posts.all_posts(if subject != nil do
      from p in Post,
        where: p.subject_id == ^subject.id or p.id in ^posts_tags_ids,
        limit: ^page_size,
        offset: ^offset,
        left_join: star in assoc(p, :stars),
        order_by: [desc: count(star.id), desc: p.inserted_at],
        group_by: p.id,
        select: p
    else
      from p in Post,
        where: p.id in ^posts_tags_ids,
        limit: ^page_size,
        offset: ^offset,
        left_join: star in assoc(p, :stars),
        order_by: [desc: count(star.id), desc: p.inserted_at],
        group_by: p.id,
        select: p
    end)

    render(conn, "index.json", post: post)
  end

  def create(conn, %{"post" => post_params}) do
    post_params = Map.put(post_params, "user_id", conn.assigns[:current_user].id)

    with {:ok, %Post{} = post} <- Posts.create_post(post_params) do
      broadcast("create", post)
      conn
      |> put_status(:created)
      |> put_resp_header("location", post_path(conn, :show, post))
      |> render("show.json", post: post)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    render(conn, "show.json", post: post)
  end

  def star(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)

    with {:ok, %Star{} = _star} <- Posts.star_post(id, conn.assigns[:current_user].id) do
      post = Posts.get_post!(id)
      broadcast("update", post)
      render(conn, "show.json", post: post)
    end
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    with {:ok, %Post{} = post} <- Posts.update_post(post, post_params) do
      broadcast("update", post)
      render(conn, "show.json", post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    with {:ok, %Post{}} <- Posts.delete_post(post) do
      broadcast("delete", post)
      send_resp(conn, :no_content, "")
    end
  end

  defp broadcast(event, post) do
    json = LinksApi.Web.PostView.render("post.json", %{post: post});
    LinksApi.Web.Endpoint.broadcast("posts", event, json)
  end
end
