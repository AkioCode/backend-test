defmodule BlogApi.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset
  alias BlogApi.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]
  @foreign_key_type :binary_id
  schema "posts" do
    field :title, :string
    field :content, :string
    belongs_to :users, User, foreign_key: :userId

    timestamps([inserted_at: :published, updated_at: :updated])
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :userId, :published, :updated])
    |> validate_required([:title, :userId])
  end
end
