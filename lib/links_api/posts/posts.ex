defmodule LinksApi.Posts do
  @moduledoc """
  The boundary for the Posts system.
  """

  import Ecto.{Query, Changeset}, warn: false
  alias LinksApi.Repo

  alias LinksApi.Posts.Tag
  alias LinksApi.Posts.Subject
  alias LinksApi.Posts.Star
  alias LinksApi.Posts.Post


  def create_star(attrs \\ %{}) do
    %Star{}
    |> star_changeset(attrs)
    |> Repo.insert()
  end
  defp star_changeset(%Star{} = star, attrs) do
    star
    |> cast(attrs, [:user_id, :post_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:post_id)
    |> validate_required([:user_id, :post_id])
  end


  def create_tag(attrs \\ %{}) do
    %Tag{}
    |> tag_changeset(attrs)
    |> Repo.insert()
  end
  defp tag_changeset(%Tag{} = tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_tag(:name)
    |> validate_required([:name])
  end

  defp validate_tag(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, tag) ->
      case !Regex.match?(~r/[\s ]+/, tag) && tag == LinksApi.Utils.camelcase(tag) do
        true -> []
        false -> [{field, options[:message] || "invalid tag must be lower case with no spaces"}]
      end
    end)
  end

  defp create_tag_if_not_exists(name) do
    query = from t in Tag,
          where: t.name == ^name
    tag = Repo.one(query)

    if tag == nil do
      create_tag(%{ name: name })
    else
      {:ok, tag}
    end
  end

  def get_or_create_tags(tags \\ []) do
    tags
      |> Enum.map(fn(tag) ->
        case create_tag_if_not_exists(tag) do
          {:ok, tag} -> tag
          {:err, _} -> nil
        end
      end)
      |> Enum.filter(fn(tag) -> tag != nil end)
  end


  def create_subject(attrs \\ %{}) do
    %Subject{}
    |> subject_changeset(attrs)
    |> Repo.insert()
  end
  defp subject_changeset(%Subject{} = subject, attrs) do
    subject
    |> cast(attrs, [:name])
    |> validate_subject(:name)
    |> validate_required([:name])
  end

  defp validate_subject(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, subject) ->
      words = Regex.split(~r/[\s ]+/, subject)
      camel_cased = Enum.map(words, fn(word) ->
        LinksApi.Utils.camelcase(word)
      end)

      case Enum.join(camel_cased, " ") == subject do
        true -> []
        false -> [{field, options[:message] || "invalid subject must be camel case words seperated with spaces"}]
      end
    end)
  end

  def create_subject_if_not_exists(name) do
    query = from(t in Subject,
          where: t.name == ^name)
    subject = Repo.one(query)

    if subject == nil do
      create_subject(%{ name: name })
    else
      {:ok, subject}
    end
  end

  def get_or_create_subject(subject \\ "Any") do
    case create_subject_if_not_exists(subject) do
      {:ok, subject} -> subject
      {:err, _} -> nil
    end
  end


  def put_tags_post(changeset, attrs) do
    tags = Enum.uniq(Map.get(attrs, :tags, Map.get(attrs, "tags", [])))

    if Enum.empty?(tags) do
      changeset
    else
      put_assoc(changeset, :tags, get_or_create_tags(tags))
    end
  end

  def put_subject_post(changeset, attrs) do
    subject = String.strip(Map.get(attrs, :subject, Map.get(attrs, "subject", "Any")))
    subject = if subject == "" do
      "Any"
    else
      subject
    end

    put_assoc(changeset, :subject, get_or_create_subject(subject))
  end

  defp preload_post({:ok, post}) do
    {:ok, Repo.preload(post, [:user, :subject, :tags, :stars])}
  end
  defp preload_post({:error, changeset}) do
    {:error, changeset}
  end

  def all_posts(query) do
    Repo.all(query)
    |> Repo.preload([:user, :subject, :tags, :stars])
  end
  def list_posts do
    Repo.all(Post)
    |> Repo.preload([:user, :subject, :tags, :stars])
  end

  def get_post!(id),
    do: Repo.get!(Post, id)
     |> Repo.preload([:user, :subject, :tags, :stars])

  def create_post(attrs \\ %{}) do
    %Post{}
    |> post_changeset(attrs)
    |> Repo.insert()
    |> preload_post()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> post_changeset(attrs)
    |> Repo.update()
    |> preload_post()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def star_post(post_id, user_id) do
    query = from s in Star,
          where: s.user_id == ^user_id and s.post_id == ^post_id
    star = Repo.one(query)

    if star == nil do
      create_star(%{
        post_id: post_id,
        user_id: user_id
      })
    else
      Repo.delete(star)
    end
  end

  def change_post(%Post{} = post) do
    post_changeset(post, %{})
  end

  defp post_changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:title, :user_id, :href])
    |> foreign_key_constraint(:user_id)
    |> validate_url(:href)
    |> unique_constraint(:href)
    |> validate_required([:title, :user_id, :href])
    |> put_tags_post(attrs)
    |> put_subject_post(attrs)
    |> foreign_key_constraint(:subject)
    |> foreign_key_constraint(:tags)
  end

  defp validate_url(changeset, field, options \\ []) do
    validate_change(changeset, field, fn(_, url) ->
      case url |> String.to_char_list |> :http_uri.parse do
        {:ok, _} -> []
        {:error, msg} -> [{field, options[:message] || "invalid url: #{inspect msg}"}]
      end
    end)
  end
end
