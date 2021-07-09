defmodule BlogApi.PostsTest do
  use BlogApi.DataCase

  alias BlogApi.Posts

  describe "posts" do
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

    def post_fixture(attrs \\ %{}) do
      {:ok, post} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Posts.create_post()

      post
    end

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts() == [post]
    end

    test "get_post/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      assert {:ok, %Post{} = post} = Posts.create_post(@valid_attrs)
      assert post.content == "some content"
      assert post.published == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert post.title == "some title"
      assert post.updated == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      assert {:ok, %Post{} = post} = Posts.update_post(post, @update_attrs)
      assert post.content == "some updated content"
      assert post.published == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert post.title == "some updated title"
      assert post.updated == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
