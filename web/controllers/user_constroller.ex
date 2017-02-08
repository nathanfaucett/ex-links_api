defmodule LinksApi.UserController do
  use LinksApi.Web, :controller

  alias LinksApi.User
  alias LinksApi.Session

  plug :scrub_params, "user" when action in [:create]
  plug LinksApi.Plug.Authenticate when action in [:confirm, :resend_confirmation_token]

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        session_changeset = Session.registration_changeset(%Session{}, %{user_id: user.id})
        {:ok, session} = Repo.insert(session_changeset)

        LinksApi.Email.confirmation_html_email(%{
          email: user.email,
          token: user.confirmation_token
        }) |> LinksApi.Mailer.deliver_now

        conn
          |> put_status(:created)
          |> render("show.json", user: user, session: session)
      {:error, changeset} ->
        conn
          |> put_status(:unprocessable_entity)
          |> render(LinksApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def confirm(conn, %{"token" => token}) do
    user = conn.assigns[:current_user]

    if user.confirmed do
      conn
        |> put_status(:no_content)
        |> json("")
        |> halt
    else
      if user.confirmation_token == token do
        changeset = User.changeset(user, %{
          confirmed: true,
          confirmation_token: nil
        })

        case Repo.update(changeset) do
          {:ok, _user} ->
            conn
              |> put_status(:no_content)
              |> json("")
              |> halt
          {:error, changeset} ->
            conn
              |> put_status(:unprocessable_entity)
              |> render(LinksApi.ChangesetView, "error.json", changeset: changeset)
        end
      else
        conn
          |> put_status(:unauthorized)
          |> render("error.json")
      end
    end
  end

  def resend_confirmation_token(conn, _params) do
    user = conn.assigns[:current_user]
    confirmation_token = SecureRandom.urlsafe_base64()

    changeset = User.changeset(user, %{
      confirmation_token: confirmation_token
    })

    case Repo.update(changeset) do
      {:ok, user} ->

        LinksApi.Email.confirmation_html_email(%{
          email: user.email,
          token: confirmation_token
        }) |> LinksApi.Mailer.deliver_now

        conn
          |> put_status(:no_content)
          |> json("")
          |> halt
      {:error, _changeset} ->
        conn
          |> put_status(:unauthorized)
          |> render("error.json")
    end
  end
end
