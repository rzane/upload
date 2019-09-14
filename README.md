[![Build Status](https://travis-ci.org/rzane/upload.svg?branch=master)](https://travis-ci.org/rzane/upload)
[![Coverage Status](https://coveralls.io/repos/github/rzane/upload/badge.svg)](https://coveralls.io/github/rzane/upload)

# Upload

An opinionated file uploader for Elixir projects.

Upload offers the following features:

- Minimal API
- Reasonable defaults
- Ecto integration
- Multiple storage adapters

## TODO

- [] Serve with a Plug
- [] File analysis
- [] Image variants

## Installation

The package can be installed by adding `upload` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:upload, "~> 0.1.0"}
  ]
end
```

## Usage

Upload a file:

```elixir
{:ok, upload} = Upload.cast_path("/path/to/file.txt")

# Transfer the upload to storage
{:ok, upload} = Upload.transfer(upload)

# Get the URL for the upload
Upload.get_url(upload)
```

### Ecto Integration

Add a column to store a logo:

```elixir
def change do
  alter table(:companies) do
    add :logo, :string
  end
end
```

Add a field to your schema:

```elixir
schema "companies" do
  field :logo, :string
end
```

Cast the upload in your changeset:

```elixir
def changeset(company, attrs \\ %{}) do
  company
  |> cast(attrs, [])
  |> cast_upload(:logo)
end
```

Upload in the controller:

```elixir
def create(conn, %{"logo" => logo}) do
  changeset = Company.changeset(%Company{}, %{"logo" => logo})

  case Repo.insert(changeset) do
    {:ok, company} ->
      # Insert succeeded. Now, you can get the URL:
      Upload.get_url(company.logo)

    {:error, changeset} ->
      # You know the drill.
  end
end
```
