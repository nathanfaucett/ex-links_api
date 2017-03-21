defmodule LinksApi.Accounts.User do
  use Ecto.Schema

  schema "accounts_users" do
    field :email, :string

    timestamps()
  end
end
