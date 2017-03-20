defmodule LinksApi.Accounts.Session do
  use Ecto.Schema

  @primary_key {:token, :string, []}
  schema "accounts_sessions" do
    belongs_to :user, LinksApi.Accounts.User
    
    timestamps()
  end
end
