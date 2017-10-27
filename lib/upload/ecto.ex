if Code.ensure_compiled? Ecto do
  defmodule Upload.Ecto do
    import Ecto.Changeset, only: [
      put_change: 3,
      prepare_changes: 2,
      add_error: 3
    ]

    @doc """
    Casts an upload in the params under the given key, uploads it, and assigns it to the field.

    Any options passed to this function will be passed through to `Upload.cast`.

    You can also provide an option `:with`, which will allow you to use a custom uploader. You can use this mechanism to add validation to your file uploads. See the documentation about `Upload.Uploader` for more information.

    ## Example

        def changeset(user, params \\ %{}) do
          user
          |> cast(params, [:name])
          |> Upload.Ecto.cast_upload(:logo)
        end

        def changeset(user, params \\ %{}) do
          user
          |> cast(params, [:name])
          |> Upload.Ecto.cast_upload(:logo, prefix: ["logos"])
        end

        def changeset(user, params \\ %{}) do
          user
          |> cast(params, [:name])
          |> Upload.Ecto.cast_upload(:logo, with: MyCustomUploader)
        end

    """
    @spec cast_upload(Ecto.Changeset.t, atom, list) :: Ecto.Changeset.t
    def cast_upload(changeset, field, opts \\ []) do
      do_cast(:cast, changeset, field, opts)
    end

    @doc """
    Casts a path in the params under a given key, uploads it, and assigns it to the field.

    This function accepts the same options that `Upload.Ecto.cast_upload/2` accepts.

    """
    @spec cast_upload_path(Ecto.Changeset.t, atom, list) :: Ecto.Changeset.t
    def cast_upload_path(changeset, field, opts \\ []) do
      do_cast(:cast_path, changeset, field, opts)
    end

    defp do_cast(action, changeset, field, opts) do
      value = Map.get(changeset.params, Atom.to_string(field))
      {uploader, cast_opts} = Keyword.pop(opts, :with, Upload)

      case apply(uploader, action, [value, cast_opts]) do
        {:ok, upload} ->
          put_upload(changeset, field, upload, opts)

        :error ->
          changeset

        {:error, message} when is_binary(message) ->
          Ecto.Changeset.add_error(changeset, field, message)

        other ->
          raise """
          Expected #{inspect uploader}.#{action}/2 to return one of the following:

            {:ok, %Upload{}}          - Casting was successful
            :error                    - Unable to cast value, ignore it
            {:error, "error message"} - Validation error

          Instead, it returned:

            #{inspect other}
          """
      end
    end

    @doc """
    Add the Upload's key to the changeset for the given field.

    If the file hasn't been uploaded yet, it will be.
    """
    @spec put_upload(Ecto.Changeset.t, atom, Upload.t, list) :: Ecto.Changeset.t
    def put_upload(changeset, field, upload, opts \\ [])
    def put_upload(changeset, field, %Upload{status: :pending, key: key} = upload, opts) do
      uploader = Keyword.get(opts, :with, Upload)

      changeset
      |> put_change(field, key)
      |> prepare_changes(fn changeset ->
        case uploader.transfer(upload) do
          {:ok, upload} ->
            put_upload(changeset, field, upload)

          {:error, message} when is_binary(message) ->
            add_error(changeset, field, message)

          other ->
            raise """
            Expected #{inspect uploader}.transfer/1 to return one of the following:

              {:ok, %Upload{}}
              {:error, "error message"}

            Instead, it returned:

              #{inspect other}
            """
        end
      end)
    end
    def put_upload(changeset, field, %Upload{status: :transferred, key: key}, _opts) do
      put_change(changeset, field, key)
    end
  end
end
