defmodule LinksApi.Accounts do
  use LinksApi.Web, :controller
  @moduledoc """
  The boundary for the Accounts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias LinksApi.Repo

  alias LinksApi.Accounts.User
  alias LinksApi.Accounts.Session


  def get_user!(id), do: Repo.get_by!(User, id: id)
  def get_user(id), do: Repo.get_by(User, id: id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> user_changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_user(attrs \\ %{}) do
    user = Repo.get_by(User, email: attrs.email)

    if user == nil do
      {:ok, user} = create_user(attrs)
      user
    else
      user
    end
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    user_changeset(user, %{})
  end

  defp user_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end

  alias LinksApi.Accounts.Session


  def get_session!(token), do: Repo.get_by!(Session, token: token)
  def get_session_by_user!(user), do: Repo.get_by!(Session, user_id: user.id)
  def get_session_by_user_id!(user_id), do: Repo.get_by!(Session, user_id: user_id)
  def get_session_from_conn(conn) do
    case get_req_header(conn, "x-links-user-token") do
     [token] ->
         Repo.get_by(Session, token: token)
     _ ->
       nil
    end
  end

  def create_session(attrs \\ %{}) do
    %Session{}
    |> session_changeset(attrs)
    |> Repo.insert()
  end

  def delete_session(%Session{} = session) do
    Repo.delete(session)
  end

  def change_session(%Session{} = session) do
    session_changeset(session, %{})
  end

  defp session_changeset(%Session{} = session, attrs) do
    session
    |> cast(attrs, [:user_id, :token])
    |> validate_required([:user_id, :token])
  end
end
