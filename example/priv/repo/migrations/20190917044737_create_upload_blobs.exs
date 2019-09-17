defmodule Upload.Test.Repo.Migrations.Setup do
  use Ecto.Migration

  def change do
    create table(:upload_blobs) do
      add(:key, :string, null: false)
      add(:filename, :string, null: false)
      add(:content_type, :string)
      add(:metadata, :map)
      add(:byte_size, :integer, null: false)
      add(:checksum, :string, null: false)
      timestamps(updated_at: false)
    end

    unique_index(:upload_blobs, :key)
  end
end
