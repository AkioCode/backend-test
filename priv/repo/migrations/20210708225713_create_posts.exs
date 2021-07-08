defmodule BlogApi.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :userId, references(:users, on_delete: :delete_all, on_update: :update_all, type: :binary_id), null: false

      timestamps([inserted_at: :published, type: :utc_datetime, updated_at: :updated, type: :utc_datetime])
    end

    create index(:posts, [:userId])
  end
end
