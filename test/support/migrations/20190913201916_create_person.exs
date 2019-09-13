defmodule Upload.Test.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :avatar, :map
    end
  end
end
