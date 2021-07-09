defmodule BlogApiWeb.UserControllerTest do
  use BlogApiWeb.ConnCase

  alias BlogApi.Accounts

  @create_attrs %{
    displayName: "some displayName",
    email: "some@email",
    image: "some image",
    password: "some password"
  }
  @update_attrs %{
    displayName: "some updated displayName",
    email: "some updated email",
    image: "some updated image",
    password: "some updated password"
  }
  @invalid_attrs %{displayName: nil, email: nil, image: nil, password: nil}

  setup_all do
    Ecto.Adapters.SQL.Sandbox.checkin(BlogApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

    %{user: user} = create_user(nil)

    on_exit fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BlogApi.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

      Accounts.delete_user(user)
      :ok
    end

    %{user: user}
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "create user " do
    test "when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), @create_attrs)
      assert conn.status == 201
      assert %{"token" => _token} = Jason.decode!(conn.resp_body)
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
      assert %{"message" => "\"password\" length must be at least 6 characters long"} = Jason.decode!(conn.resp_body)
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
      conn = post(conn, Routes.user_path(conn, :create), %{displayName: "a", email: "some@mail", password: "123456"})
      assert conn.status == 400
      assert %{"message" => "\"displayName\" length must be at least 8 characters long"} = Jason.decode!(conn.resp_body)
    end

    test "with used email", %{conn: conn} do
      post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: "123456"})
      conn = post(conn, Routes.user_path(conn, :create), %{email: "some@mail", password: "123456"})
      assert conn.status == 400
      assert %{"message" => "Usuário já existe"} = Jason.decode!(conn.resp_body)
    end
  end

  describe "login " do
    test "with valid params", %{conn: conn, user: user} do
      conn = post(conn, Routes.user_path(conn, :login), %{email: user.email, password: user.password})
      assert conn.status == 200
      assert %{"token" => _token} = Jason.decode!(conn.resp_body)
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

  describe "update user" do
    setup [:create_user]

    test "redirects when data is valid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @update_attrs)
      assert redirected_to(conn) == Routes.user_path(conn, :show, user)

      conn = get(conn, Routes.user_path(conn, :show, user))
      assert html_response(conn, 200) =~ "some updated displayName"
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put(conn, Routes.user_path(conn, :update, user), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    %{user: user}
  end
end
