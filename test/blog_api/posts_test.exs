defmodule BlogApi.PostsTest do
  use BlogApi.DataCase

  alias BlogApi.Accounts
  alias BlogApi.Posts
  alias BlogApi.Posts.Post

  @valid_attrs %{
    content: "some content",
    published: "2010-04-17T14:00:00Z",
    title: "some title",
    updated: "2010-04-17T14:00:00Z"
  }
  @update_attrs %{
    content: "some updated content",
    published: "2011-05-18T15:01:01Z",
    title: "some updated title",
    updated: "2011-05-18T15:01:01Z"
  }
  @invalid_attrs %{content: nil, published: nil, title: nil, updated: nil}

  @create_user_attrs %{
    displayName: "some displayName",
    email: "some@email",
    image: "some image",
    password: "some password"
  }

  setup_all do
    Ecto.Adapters.SQL.Sandbox.checkin(BlogApi.Repo)
    Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

    user = user_fixture(nil)
    post = post_fixture(%{userId: user.id})

    on_exit(fn ->
      # this callback needs to checkout its own connection since it
      # runs in its own process
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(BlogApi.Repo)
      Ecto.Adapters.SQL.Sandbox.mode(BlogApi.Repo, :auto)

      Accounts.delete_user(user)
      :ok
    end)

    %{user: user, post: post}
  end

  def user_fixture(_) do
    {:ok, user} = Accounts.create_user(@create_user_attrs)
    user
  end

  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(@valid_attrs)
      |> Posts.create_post()

    post
  end

  describe "posts" do
    test "list_posts/0 returns all posts", %{post: post} do
      assert Posts.list_posts() == [post]
    end

    test "get_post/1 returns the post with given id", %{post: post} do
      assert Posts.get_post(post.id) == post
    end

    test "create_post/1 with valid data creates a post", %{user: user} do
      assert {:ok, %Post{} = post} =
        Map.put_new(@valid_attrs, :userId, user.id)
        |> Posts.create_post()
      assert post.content == "some content"
      assert post.published == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert post.title == "some title"
      assert post.updated == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post", %{post: post} do
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.content == "some updated content"
      assert post.published == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert post.title == "some updated title"
      assert post.updated == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_post/2 with invalid data returns error changeset", %{post: post} do
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post(post.id)
    end

    test "delete_post/1 deletes the post", %{post: post} do
      assert {:ok, %Post{}} = Posts.delete_post(post)
    end

    test "change_post/1 returns a post changeset", %{post: post} do
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
