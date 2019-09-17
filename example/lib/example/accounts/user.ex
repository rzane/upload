defmodule Example.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Upload.Changeset

  schema "users" do
    field :name, :string
    belongs_to :avatar, Upload.Blob
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name])
    |> cast_upload(:avatar)
    |> validate_required([:name])
  end
end
