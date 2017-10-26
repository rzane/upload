defmodule Upload.EctoTest do
  use ExUnit.Case, async: true
  doctest Upload.Ecto, except: [cast_upload: 3]
end
