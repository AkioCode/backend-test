defmodule BlogApiWeb.PostController do
  use BlogApiWeb, :controller
  alias BlogApi.Accounts.Guardian
  alias BlogApi.Posts
  alias BlogApi.Posts.Post

  action_fallback BlogApiWeb.FallbackController

  def index(conn, %{"q" => search_term}) do
    posts = Posts.list_posts_with_user(search_term)
    render(conn, "index_with_user.json", %{posts: posts})
  end

  def index(conn, _params) do
    posts = Posts.list_posts_with_user()
    render(conn, "index_with_user.json", %{posts: posts})
  end

  def create(conn, %{"title" => _title, "content" => _content} = entries) do
    user = Guardian.current_user(conn)
    params = Map.put_new(entries, "userId", user.id)

    with {:ok, post} <- Posts.create_post(params) do
      conn
      |> put_status(201)
      |> json(%{title: post.title, content: post.content, userId: post.userId})
    end
  end

  def create(_conn, %{"title" => _title}), do: {:error, "\"title\" is required"}

  def create(_conn, %{"content" => _content}), do: {:error, "\"content\" is required"}

  def show(conn, %{"id" => id}) do
    with %Post{} = post <- Posts.get_post_with_user(id) do
      render(conn, "show_with_user.json", post: post)
    end
  end

  def update(conn, %{"id" => id, "title" => _title, "content" => _content} = params) do
    user = Guardian.current_user(conn)
    with  %Post{} = post <- Posts.get_post(id),
          true <- post.userId == user.id,
          {:ok, updated_post} <- Posts.update_post(post, params) do

        conn
        |> put_status(:ok)
        |> json(%{title: updated_post.title, content: updated_post.content, userId: updated_post.userId})
    else
      false ->
        {:error, "Usuário não autorizado", 401}

      {:error, message, status} ->
        {:error, message, status}
    end
  end

  def update(_conn, %{"title" => _title}), do: {:error, "\"title\" is required"}

  def update(_conn, %{"content" => _content}), do: {:error, "\"content\" is required"}

  def delete(conn, %{"id" => id}) do
    user = Guardian.current_user(conn)
    with  %Post{} = post <- Posts.get_post(id),
          true <- post.userId == user.id,
          {:ok, _post} = Posts.delete_post(post) do
      conn
      |> Plug.Conn.send_resp(204, [])
    else
      false ->
        {:error, "Usuário não autorizado", 401}

      {:error, message, status} ->
        {:error, message, status}
    end
  end
end
