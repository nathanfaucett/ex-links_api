defmodule LinksApi.PostController do
  use LinksApi.Web, :controller
  require Logger

  alias LinksApi.Post
  alias LinksApi.Tag
  alias LinksApi.Subject
  alias LinksApi.PostsTags

  plug LinksApi.Plug.Authenticate when action in [:create, :update, :delete, :star]

  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "order_by_stars" => "true"
  }) do
    post = from(p in Post,
      limit: ^page_size,
      offset: ^offset,
      left_join: star in assoc(p, :stars),
      order_by: [desc: count(star.id), desc: p.inserted_at],
      group_by: p.id,
      select: p
    )
    |> Repo.all
    |> Repo.preload([:user, :subject, :tags, :stars])

    Logger.debug "index pop"

    render(conn, "index.json", post: post)
  end

  def index(conn, %{
    "page_size" => page_size,
    "offset" => offset,
    "order_by_stars" => "false"
  }) do
    post = from(p in Post,
      limit: ^page_size,
      offset: ^offset,
      order_by: [desc: p.inserted_at]
    )
    |> Repo.all
    |> Repo.preload([:user, :subject, :tags, :stars])

    Logger.debug "index newest"

    render(conn, "index.json", post: post)
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
      "tags" => %{"0" => "All"}
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
    subject = Repo.get_by Subject, name: subject
    tags = Map.values(tags)

    tag_ids = Repo.all(from t in Tag,
      where: t.name in ^tags,
      select: t.id)

    posts_tags_ids = Repo.all(from pt in PostsTags,
      where: pt.tag_id in ^tag_ids,
      select: pt.post_id)

    post = if subject != nil do
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
      end
      |> Repo.all
      |> Repo.preload([:user, :subject, :tags, :stars])

    render(conn, "index.json", post: post)
  end

  def create(conn, %{"post" => post_params}) do
    user = conn.assigns[:current_user]
    post_params = Map.put(post_params, "user_id", user.id)
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        post = post
          |> Repo.preload([:user, :subject, :tags, :stars])

        broadcast("create", post);

        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json", post: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(LinksApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def star(conn, %{"id" => id}) do
    {id, _} = Integer.parse(id)

    case LinksApi.Star.star(id, conn.assigns[:current_user].id) do
      {:ok, _star} ->
        post = Repo.get!(Post, id)
          |> Repo.preload([:user, :subject, :tags, :stars])

        broadcast("update", post);

        render(conn, "show.json", post: post)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(LinksApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
      |> Repo.preload([:user, :subject, :tags, :stars])
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
      |> Repo.preload([:user, :subject, :tags, :stars])

    if post.user.id == conn.assigns[:current_user].id do
      changeset = Post.changeset(post, post_params)

      case Repo.update(changeset) do
        {:ok, post} ->
          post = post
            |> Repo.preload([:user, :subject, :tags, :stars])

          broadcast("update", post);

          render(conn, "show.json", post: post)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(LinksApi.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
        |> put_status(:unauthorized)
        |> render(LinksApi.ErrorView, "401.json")
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
      |> Repo.preload([:user, :subject, :tags, :stars])

    if post.user.id == conn.assigns[:current_user].id do
      Repo.delete!(post)
      broadcast("delete", post);
      send_resp(conn, :no_content, "")
    else
      conn
        |> put_status(:unauthorized)
        |> render(LinksApi.ErrorView, "401.json")
    end
  end

  defp broadcast(event, post) do
    json = LinksApi.PostView.render("post.json", %{post: post});
    LinksApi.Endpoint.broadcast("posts", event, json)
  end
end
