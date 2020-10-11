defmodule Upload.Test.Person do
  use Ecto.Schema

  import Ecto.Changeset

  schema "people" do
    belongs_to(:avatar, Upload.Blob)
  end

  def changeset(person, attrs \\ %{}) do
    cast(person, attrs, [])
  end
end
