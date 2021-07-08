defmodule BlogApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :displayName, :string
      add :email, :string, null: false
      add :password, :string, null: false
      add :image, :text

      timestamps()
    end

    create index("users", [:email], unique: true)
  end
end
