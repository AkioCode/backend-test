defmodule BlogApiWeb.UserControllerTest do
  use BlogApiWeb.ConnCase
  alias BlogApi.Accounts.Guardian
  alias BlogApi.Accounts

  @create_attrs %{
    displayName: "some displayName",
    email: "some@email",
    image: "some image",
    password: "some password"
  }

  setup_all do
    Ecto.Adapters.SQL.Sandbox.checkin(BlogApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

    %{user: user} = create_user(nil)

    on_exit(fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BlogApi.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

      Accounts.delete_user(user)
      :ok
    end)

    %{user: user}
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.user_path(conn, :index))
      assert response.status == 200
    end

    test "index user token not found", %{conn: conn} do
      response = get(conn, Routes.user_path(conn, :index))
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "index user invalid token", %{conn: conn} do
      response =
        conn
        |> put_req_header("authorization", "Bearer 123456")
        |> get(Routes.user_path(conn, :index))

      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end

    test "show a valid user", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.user_path(conn, :show, user.id))
      assert response.status == 200
    end

    test "show (him/her)self", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.user_path(conn, :show, "me"))
      assert response.status == 200
    end

    test "show user token not found", %{conn: conn} do
      response = get(conn, Routes.user_path(conn, :show, "me"))
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "show user invalid token", %{conn: conn} do
      response =
        conn
        |> put_req_header("authorization", "Bearer 123456")
        |> get(Routes.user_path(conn, :show, "me"))

      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end

    test "show an invalid user", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = get(conn, Routes.user_path(conn, :show, "-1"))
      assert response.status == 404
      assert "Usuário não existe" == Jason.decode!(response.resp_body)["message"]
    end
  end

  describe "create user " do
    test "when data is valid", %{conn: conn} do
      sample = %{
        displayName: "Display Name",
        email: "display@email",
        image: "some image",
        password: "some password"
      }

      response = post(conn, Routes.user_path(conn, :create), sample)
      assert response.status == 201
      assert %{"token" => _token} = Jason.decode!(response.resp_body)
    end

    test "when password is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{email: "some@mail"})
      assert conn.status == 400
      assert %{"message" => "\"password\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when password is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: ""})
      assert conn.status == 400
      assert %{"message" => "\"password\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when password is less than 6", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: "1"})
      assert conn.status == 400

      assert %{"message" => "\"password\" length must be at least 6 characters long"} =
               Jason.decode!(conn.resp_body)
    end

    test "when email is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{password: "some@mail"})
      assert conn.status == 400
      assert %{"message" => "\"email\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when email has invalid format", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{email: "nil", password: "123456"})
      assert conn.status == 400
      assert %{"message" => "\"email\" must be a valid email"} = Jason.decode!(conn.resp_body)
    end

    test "when email is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), %{email: "", password: "some@mail"})
      assert conn.status == 400
      assert %{"message" => "\"email\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when displayName is less than 8", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :create), %{
          displayName: "a",
          email: "some@mail",
          password: "123456"
        })

      assert conn.status == 400

      assert %{"message" => "\"displayName\" length must be at least 8 characters long"} =
               Jason.decode!(conn.resp_body)
    end

    test "with used email", %{conn: conn} do
      post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: "123456"})

      conn =
        post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: "123456"})

      assert conn.status == 400
      assert %{"message" => "Usuário já existe"} = Jason.decode!(conn.resp_body)
    end
  end

  describe "login " do
    test "with valid params", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login), %{email: user.email, password: user.password})

      assert conn.status == 200
      assert %{"token" => _token} = Jason.decode!(conn.resp_body)
    end

    test "with invalid credentials", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_path(conn, :login), %{email: user.email, password: "user.password"})

      assert conn.status == 400
      assert %{"message" => "Campos inválidos"} = Jason.decode!(conn.resp_body)
    end

    test "when password is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), %{email: "some@mail"})
      assert conn.status == 400
      assert %{"message" => "\"password\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when password is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), %{email: "some@mail", password: ""})
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["message"] =~ "\"password\" is not allowed to be empty"
    end

    test "when email is nil", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), %{password: "some@mail"})
      assert conn.status == 400
      assert %{"message" => "\"email\" is required"} = Jason.decode!(conn.resp_body)
    end

    test "when email is empty", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :login), %{email: "", password: "some@mail"})
      assert conn.status == 400
      assert Jason.decode!(conn.resp_body)["message"] =~ "\"email\" is not allowed to be empty"
    end
  end

  describe "delete user" do
    test " (him/her)self", %{conn: conn, user: user} do
      conn = Guardian.Plug.sign_in(conn, user)
      response = delete(conn, "/user/me")
      assert response.status == 204
      assert nil == BlogApi.Repo.get(BlogApi.Accounts.User, user.id)
    end

    test "token not found", %{conn: conn} do
      response = delete(conn, "/user/me")
      assert response.status == 401
      assert "Token não encontrado" == Jason.decode!(response.resp_body)["message"]
    end

    test "invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer 123456")

      response = delete(conn, "/user/me")
      assert response.status == 401
      assert "Token inválido ou expirado" == Jason.decode!(response.resp_body)["message"]
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
