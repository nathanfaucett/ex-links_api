# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     LinksApi.Repo.insert!(%LinksApi.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


LinksApi.Repo.insert!(LinksApi.User.registration_changeset(%LinksApi.User{}, %{
  email: "example@domain.com",
  password: "password",
  confirmed: true,
  confirmation_token: nil
}))
