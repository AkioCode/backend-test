defmodule BlogApi.AccountsTest do
  use BlogApi.DataCase

  alias BlogApi.Accounts

  describe "users" do
    alias BlogApi.Accounts.User

    @valid_attrs %{
      displayName: "some displayName",
      email: "some@email",
      image: "some image",
      password: "some password"
    }
    @update_attrs %{
      displayName: "some updated displayName",
      email: "some updated@email",
      image: "some updated image",
      password: "some updated password"
    }
    @invalid_attrs %{displayName: nil, email: nil, image: nil, password: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.displayName == "some displayName"
      assert user.email == "some@email"
      assert user.image == "some image"
      assert user.password == "some password"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.displayName == "some updated displayName"
      assert user.email == "some updated@email"
      assert user.image == "some updated image"
      assert user.password == "some updated password"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
    end
  end
end
