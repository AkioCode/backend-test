defmodule BlogApiWeb.PostView do
  use BlogApiWeb, :view

  def render("index_with_user.json", %{posts: posts}) do
    render_many(posts, BlogApiWeb.PostView, "show_with_user.json")
  end

  def render("index.json", %{posts: posts}) do
    render_many(posts, BlogApiWeb.PostView, "show.json")
  end

  def render("show_with_user.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      published: post.published,
      updated: post.updated,
      user: render_one(post.user, BlogApiWeb.UserView, "show.json")
    }
  end

  def render("show.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      content: post.content,
      userId: post.userId,
      published: post.published,
      updated: post.updated
    }
  end
end
