defmodule Example.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :avatar_id, references(:upload_blobs)
      timestamps()
    end
  end
end
