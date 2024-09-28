defmodule Lollygagging.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Lollygagging.Repo
  alias Lollygagging.Timeline.Post
  alias Lollygagging.Timeline.Query.Post, as: QueryPost

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  def list_posts(criteria) do
    Post
    |> where(^QueryPost.posts_by_criteria(criteria))
    |> order_by([p], [{:desc, :inserted_at}])
    |> limit([p], 20)
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    Post
    |> Repo.get!(id)
    |> Repo.preload(children: from(p in Post, order_by: [{:desc, :inserted_at}]))
  end

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def inc_likes(id) do
    {_, [post]} =
      Post
      |> where([p], p.id == ^id)
      |> select([p], p)
      |> Repo.update_all(inc: [likes_count: 1])

    {:ok, Repo.preload(post, [:children])}
  end

  def subscribe, do: Phoenix.PubSub.subscribe(Lollygagging.PubSub, "posts")

  def broadcast(post, event) do
    Phoenix.PubSub.broadcast(Lollygagging.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
