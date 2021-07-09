defmodule BlogApi.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  alias BlogApi.Repo
  alias BlogApi.Posts.Post

  def list_posts do
    Repo.all(Post)
  end

  def get_post(id) do
    with {:ok, _uuid} <- Ecto.UUID.cast(id),
         %Post{} = post <- Repo.get(Post, id) do
      post
    else
      :error ->
        {:error, "Post não existe", 404}

      nil ->
        {:error, "Post não existe", 404}
    end
  end

  def list_posts_with_user() do
    from(
      post in Post,
      join: user in assoc(post, :user),
      preload: [user: user]
    )
    |> Repo.all()
  end

  def get_post_with_user(id) do
    with {:ok, _uuid} <- Ecto.UUID.cast(id),
         %Post{} = post <- query_post_preloaded_user(id) do
      post
    else
      :error ->
        {:error, "Post não existe", 404}

      {:error, message, status} ->
        {:error, message, status}
    end
  end

  def query_post_preloaded_user(id) do
    from(
      post in Post,
      join: user in assoc(post, :user),
      where: post.id == ^id,
      preload: [user: user]
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, "Post não existe", 404}

      post ->
        post
    end
  end

  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
