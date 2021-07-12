defmodule BlogApiWeb.PostControllerTest do
  use BlogApiWeb.ConnCase

  alias BlogApi.Posts
  alias BlogApi.Accounts
  alias BlogApi.Accounts.Guardian

  @create_attrs %{
    content: "some content",
    published: "2010-04-17T14:00:00Z",
    title: "some title",
    updated: "2010-04-17T14:00:00Z"
  }
  @update_attrs %{
    content: "some updated content",
    title: "some updated title"
  }
  @create_user_attrs %{
    displayName: "some displayName",
    email: "some@email",
    image: "some image",
    password: "some password"
  }

  setup_all do
    Ecto.Adapters.SQL.Sandbox.checkin(BlogApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

    %{user: user} = create_user(nil)
    {:ok, user2} = Accounts.create_user(%{email: "a@mail.com", password: "basodijoadijgoaidj"})
    %{post: post} = create_post(user.id)
    %{post: user2_post} = create_post(user2.id)

    on_exit(fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BlogApi.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

      Accounts.delete_user(user)
      Accounts.delete_user(user2)
      :ok
    end)

    %{user: user, post: post, user2_post: user2_post}
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    user
  end

  def fixture(:post, userId) do
    {:ok, post} =
      @create_attrs
      |> Map.put_new(:userId, userId)
      |> Posts.create_post()

    post
  end

  describe "index" do
    test "lists all posts", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.post_path(conn, :index))
      assert response.status == 200
    end

    test "token not found", %{conn: conn} do
      response = get(conn, Routes.post_path(conn, :index))
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123456")

      response = get(conn, Routes.post_path(conn, :index))
      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end

    test "show a valid post", %{conn: conn, user: user, post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.post_path(conn, :show, post.id))
      assert response.status == 200
    end

    test "show an invalid post", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.post_path(conn, :show, "id"))
      assert response.status == 404
    end

    test "show user token not found", %{conn: conn} do
      response = get(conn, Routes.post_path(conn, :show, "id"))
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "show user invalid token", %{conn: conn} do
      response =
        conn
        |> put_req_header("authorization", "Bearer 123456")
        |> get(Routes.post_path(conn, :show, "id"))

      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  describe "get post by " do
    test "valid query", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      query = "content"
      response = get(conn, "/post?=#{query}")
      resp_body = Jason.decode!(response.resp_body)
      result = BlogApi.Posts.list_posts_with_user(query)

      assert response.status == 200
      assert length(resp_body) == length(result)
    end

    test "token not found", %{conn: conn} do
      query = "content"
      response = get(conn, "/post?=#{query}")
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn} do
      query = "content"

      response =
        conn
        |> put_req_header("authorization", "Bearer 123456")
        |> get("/post?=#{query}")

      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)

      sample = %{
        content: "some other content",
        title: "some other title",
        userId: user.id
      }

      response = post(conn, Routes.post_path(conn, :create), sample)

      resp_body =
        Jason.decode!(response.resp_body)
        |> Map.new(fn {k, v} -> {String.to_atom(k), v} end)

      assert sample == resp_body
      assert response.status == 201
    end

    test "when title is nil", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = post(conn, Routes.post_path(conn, :create), %{content: "some"})

      assert response.status == 400
      assert %{"message" => "\"title\" is required"} = Jason.decode!(response.resp_body)
    end

    test "when content is nil", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = post(conn, Routes.post_path(conn, :create), %{title: "some"})

      assert response.status == 400
      assert %{"message" => "\"content\" is required"} = Jason.decode!(response.resp_body)
    end

    test "token not found", %{conn: conn} do
      response = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123456")

      response = post(conn, Routes.post_path(conn, :create), post: @create_attrs)
      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  describe "update post" do
    test "when data is valid", %{conn: conn, user: user, post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert response.status == 204
    end

    test "when post is from other user", %{conn: conn, user: user, user2_post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert response.status == 401
      assert %{"message" => "Usuário não autorizado"} = Jason.decode!(response.resp_body)
    end

    test "token not found", %{conn: conn, post: post} do
      response = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn, post: post} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123456")

      response = delete(conn, Routes.post_path(conn, :delete, post.id))
      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  describe "delete post" do
    test "when data is valid", %{conn: conn, user: user, post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = put(conn, Routes.post_path(conn, :update, post.id), @update_attrs)
      assert response.status == 200
    end

    test "when post is from other user", %{conn: conn, user: user, user2_post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = put(conn, Routes.post_path(conn, :update, post.id), @update_attrs)
      assert response.status == 401
      assert %{"message" => "Usuário não autorizado"} = Jason.decode!(response.resp_body)
    end

    test "when title is nil", %{conn: conn, user: user, post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = put(conn, Routes.post_path(conn, :update, post.id), %{content: "a"})
      assert response.status == 400
      assert %{"message" => "\"title\" is required"} = Jason.decode!(response.resp_body)
    end

    test "when content is nil", %{conn: conn, user: user, post: post} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = put(conn, Routes.post_path(conn, :update, post.id), %{title: "a"})
      assert response.status == 400
      assert %{"message" => "\"content\" is required"} = Jason.decode!(response.resp_body)
    end

    test "token not found", %{conn: conn, post: post} do
      response = put(conn, Routes.post_path(conn, :update, post.id), %{title: "a", content: "a"})
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn, post: post} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123456")

      response = put(conn, Routes.post_path(conn, :update, post.id), %{title: "a", content: "a"})
      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  defp create_post(userId) do
    post = fixture(:post, userId)
    %{post: post}
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
