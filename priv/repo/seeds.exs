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

alias LinksApi.Repo
alias LinksApi.User
alias LinksApi.Post


user = Repo.insert!(User.registration_changeset(%User{}, %{
  email: "example@domain.com",
  password: "password",
  confirmed: true,
  confirmation_token: nil
}))

Repo.insert!(Post.changeset(%Post{}, %{
  title: "Google",
  user_id: user.id,
  href: "https://www.google.com/",
  subject: "Search Engine",
  tags: ["Search", "Engine"]
}))
Repo.insert!(Post.changeset(%Post{}, %{
  title: "Yahoo",
  user_id: user.id,
  href: "https://www.yahoo.com/",
  subject: "Search Engine",
  tags: ["Search", "Engine"]
}))
