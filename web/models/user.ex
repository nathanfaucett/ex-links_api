defmodule LinksApi.User do
  use LinksApi.Web, :model


  schema "users" do
    field :email, :string

    field :confirmed, :boolean, default: false
    field :confirmation_token, :string

    field :password_hash, :string
    field :password, :string, virtual: true

    has_many :sessions, LinksApi.Session
    has_many :posts, LinksApi.Post

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
      |> cast(params, [:email, :confirmed, :confirmation_token])
      |> validate_required([:email])
      |> validate_format(:email, ~r/@/)
      |> unique_constraint(:email)
  end

  def registration_changeset(model, params \\ :empty) do
    model
      |> cast(params, [:password, :email, :confirmed, :confirmation_token])
      |> validate_required([:password, :email])
      |> validate_format(:email, ~r/@/)
      |> unique_constraint(:email)
      |> validate_length(:password, min: 6)
      |> put_change(:confirmation_token, SecureRandom.urlsafe_base64())
      |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
