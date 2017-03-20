defmodule LinksApi.Accounts.User do
  use Ecto.Schema

  @primary_key {:id, :integer, []}
  schema "accounts_users" do
    field :email, :string

    timestamps()
  end
end
