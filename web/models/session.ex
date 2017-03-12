defmodule LinksApi.Session do
  use Phoenix.Controller

  use LinksApi.Web, :model

  schema "sessions" do
    field :token, :string
    belongs_to :user, LinksApi.User

    timestamps()
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
      |> cast(params, [:user_id])
      |> validate_required([:user_id])
  end

  def registration_changeset(model, params \\ :empty) do
    model
      |> changeset(params)
      |> put_change(:token, SecureRandom.urlsafe_base64())
  end

  def get_session(conn) do
    case get_req_header(conn, "x-links-user-token") do
      [token] ->
          LinksApi.Repo.get_by(LinksApi.Session, token: token)
      _ ->
        nil
    end
  end
end
