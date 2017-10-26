defmodule Upload.User do
  @moduledoc """
  Just and ecto schema used for testing.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :picture, :string
  end

  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [:name])
  end
end
