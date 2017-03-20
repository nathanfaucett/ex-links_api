defmodule LinksApi.Web.SubjectView do
  use LinksApi.Web, :view
  alias LinksApi.Web.SubjectView

  def render("index.json", %{subjects: subjects}) do
    %{data: render_many(subjects, SubjectView, "subject.json")}
  end

  def render("show.json", %{subject: subject}) do
    %{data: render_one(subject, SubjectView, "subject.json")}
  end

  def render("subject.json", %{subject: subject}) do
    %{id: subject.id,
      name: subject.name}
  end
end
