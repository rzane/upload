# Upload

Upload files and get URLs for them. Nothing more.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `upload` to your list of dependencies in `mix.exs`:

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
with {:ok, upload} <- Upload.cast_path("/path/to/file.txt"),
     {:ok, upload} <- Upload.transfer(upload),
     do: {:ok, Upload.get_url(upload.key)}
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
def changeset(struct, attrs \\ %{}) do
  struct
  |> cast(attrs, [:name])
  |> Upload.Ecto.cast_upload(:logo, prefix: ["logos"])
end
```

Upload in the controller:

```elixir
def create(conn, %{"logo" => logo}) do
  changeset = Company.changeset(%Company{}, %{"logo" => logo})

  case Repo.insert(changeset) do
    {:ok, company} ->
      # Insert succeeded, now you can get the URL:
      Upload.get_url(company.logo)

    {:error, changeset} ->
      # You know the drill.
  end
end
```

### Serving static files

In order to serve the files, you'll need to setup `Plug.Static`.

If you're using Phoenix, you can add this line to `endpoint.ex`:

```elixir
plug Plug.Static, at: "/", from: :your_app, gzip: false, only: ~w(uploads)
```

## Configuration

For now, there are four adapters:

* `Upload.Adapters.Local` - Save files to your local filesystem.
* `Upload.Adapters.S3` - Save files to Amazon S3.
* `Upload.Adapters.Fake` - Don't actually save the files at all.
* `Upload.Adapters.Test` - Keep uploaded files in state, so that you can assert.

### `Upload.Adapters.Local`

Out of the box, `Upload` is ready to go with some sane defaults (for development, at least).

Here are the default values:

```elixir
config :upload, Upload,
  adapter: Upload.Adapters.Local

config :upload, Upload.Adapters.Local,
  storage_path: "priv/static/uploads",
  public_path: "/uploads"
```

### `Upload.Adapters.S3`

To use the AWS adapter, you'll to install [ExAws](https://github.com/ex-aws/ex_aws).

Then, you'll need to following configuration:

```elixir
config :upload, Upload, adapter: Upload.Adapters.S3
config :upload, Upload.Adapters.S3, bucket: "your_bucket_name"
```

### `Upload.Adapters.Test`

To use this adapter, you'll need to the following configuration:

```elixir
config :upload, Upload, adapter: Upload.Adapters.Test
```

In your tests, you can make assertions:

```elixir
setup do
  {:ok, _} = start_supervised(Upload.Adapters.Test)
  :ok
end

test "files are uploaded" do
  assert {:ok, upload} = Upload.cast_path("/path/to/file.txt")
  assert {:ok, upload} = Upload.transfer(upload)
  assert length(Upload.Adapters.Test.get_uploads()) == 1
end
```

### `Upload.Adapters.Fake`

This adapter does pretty much nothing. It makes absolutely no attempt to persist uploads. This can be useful in unit tests where you want to completely bypass uploading.

To use this adapter, you'll need the following configuration:

```elixir
config :upload, Upload, adapter: Upload.Adapters.Fake
```
