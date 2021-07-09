defmodule BlogApi.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias BlogApi.Posts.Post

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :displayName, :string
    field :email, :string
    field :image, :string
    field :password, :string

    has_many :posts, Post, foreign_key: :userId
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:displayName, :email, :password, :image])
    |> validate_required([:email, :password], message: "is required")
    |> validate_length(:password, min: 6, message: "length must be at least 6 characters long")
    |> validate_length(:displayName, min: 8, message: "length must be at least 8 characters long")
    |> validate_format(:email, ~r/.+@.+/, message: "must be a valid email")
    |> unique_constraint(:email, message: "Usuário já existe")
  end
end
