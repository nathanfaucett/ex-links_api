defmodule LinksApi.PostController do
  use LinksApi.Web, :controller

  alias LinksApi.Post

  plug LinksApi.Plug.Authenticate when action in [:create, :update, :delete]

  def index(conn, _params) do
    posts = Repo.all(Post)
      |> Repo.preload([:user, :subject, :tags])
    render(conn, "index.json", post: posts)
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
