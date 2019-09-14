defmodule Upload.Test.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:uploads) do
      add(:key, :string, null: false)
      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:metadata, :map)

      # TODO: make `byte_size` and `checksum` non-nullable
      add(:byte_size, :integer)
      add(:checksum, :string)

      timestamps(updated_at: false)
    end

    unique_index(:uploads, :key)

    create table(:people) do
      add(:avatar_id, references(:uploads), null: false)
    end
  end
end
