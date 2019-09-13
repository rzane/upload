defmodule UploadTest do
  use ExUnit.Case

  defmodule Person do
    use Ecto.Schema

    schema "people" do
      embeds_one :avatar, Person.Avatar
    end
  end

  defmodule Person.Avatar do
    use Upload
  end

  test "saves a file"
end
