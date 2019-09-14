defmodule Upload.Test.Person do
  use Ecto.Schema
  import Ecto.Changeset
  import Upload.Changeset

  schema "people" do
    embeds_one :avatar, Upload.Schema
  end

  def changeset(person, attrs \\ %{}) do
    person
    |> cast(attrs, [])
    |> cast_upload(:avatar)
  end
end
