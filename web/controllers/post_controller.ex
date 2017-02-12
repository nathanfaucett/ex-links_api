defmodule LinksApi.PostController do
  use LinksApi.Web, :controller

  alias LinksApi.Post
  alias LinksApi.Tag
  alias LinksApi.Subject
  alias LinksApi.PostsTags

  plug LinksApi.Plug.Authenticate when action in [:create, :update, :delete]

  def index(conn, %{"page_size" => page_size, "offset" => offset}) do
    post = from(p in Post,
      limit: ^page_size,
      offset: ^offset
    )
    |> Repo.all
    |> Repo.preload([:user, :subject, :tags])

    render(conn, "index.json", post: post)
  end

  def index(conn, %{"subject" => subject, "tags" => tags}) do
    subject = Repo.get_by Subject, name: subject

    tag_ids = Repo.all(from t in Tag,
      where: t.name in ^tags)
      |> Enum.map(fn(tag) -> tag.id end)

    posts_tags_ids = Repo.all(from pt in PostsTags,
      where: pt.tag_id in ^tag_ids)
      |> Enum.map(fn(post_tag) -> post_tag.post_id end)

    post = if subject != nil do
        from p in Post,
          where: p.subject_id == ^subject.id or p.id in ^posts_tags_ids
      else
        from p in Post,
          where: p.id in ^posts_tags_ids
      end
      |> Repo.all
      |> Repo.preload([:user, :subject, :tags])

    render(conn, "index.json", post: post)
  end

  def create(conn, %{"post" => post_params}) do
    user = conn.assigns[:current_user]
    post_params = Map.put(post_params, "user_id", user.id)
    changeset = Post.changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        post = post
          |> Repo.preload([:user, :subject, :tags])

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

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
      |> Repo.preload([:user, :subject, :tags])
    render(conn, "show.json", post: post)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
      |> Repo.preload([:user, :subject, :tags])

    if post.user.id == conn.assigns[:current_user].id do
      changeset = Post.changeset(post, post_params)

      case Repo.update(changeset) do
        {:ok, post} ->
          post = post
            |> Repo.preload([:user, :subject, :tags])
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
      |> Repo.preload(:user)

    if post.user.id == conn.assigns[:current_user].id do
      Repo.delete!(post)
      send_resp(conn, :no_content, "")
    else
      conn
        |> put_status(:unauthorized)
        |> render(LinksApi.ErrorView, "401.json")
    end
  end
end
