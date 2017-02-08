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
alias LinksApi.Link
alias LinksApi.Tag
alias LinksApi.Subject


user =Repo.insert!(User.registration_changeset(%User{}, %{
  email: "example@domain.com",
  password: "password",
  confirmed: true,
  confirmation_token: nil
}))
link = Repo.insert!(%Link{
  href: "http://example.com"
})
tag = Repo.insert!(%Tag{
  name: "Tag"
})
subject = Repo.insert!(%Subject{
  name: "Subject"
})

Repo.insert!(%Post{
  title: "Title",
  user: user,
  link: link,
  subject: subject,
  tags: [tag]
})
