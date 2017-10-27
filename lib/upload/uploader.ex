defmodule Upload.Uploader do
  @moduledoc """
  This is a behaviour that defines how an uploader should behave. It
  comes in handy if you want to validate uploads or transform files
  before uploading.

  ### Example

     defmodule MyUploader do
        use Upload.Uploader

        def cast(file) do
          with {:ok, upload} <- Upload.cast(file) do
            extension = Upload.get_extension(upload)

            if Enum.member?(~w(.png), extension) do
              {:ok, upload}
            else
              {:error, "not a valid file extension"}
            end
          end
        end
      end

  """

  defmacro __using__(_) do
    quote do
      @behaviour Upload.Uploader

      defdelegate cast(uploadable), to: Upload
      defdelegate cast(uploadable, opts), to: Upload
      defdelegate cast_path(uploadable_path), to: Upload
      defdelegate cast_path(uploadable_path, opts), to: Upload
      defdelegate transfer(upload), to: Upload

      defoverridable [
        cast: 1,
        cast: 2,
        cast_path: 1,
        cast_path: 2,
        transfer: 1
      ]
    end
  end

  @callback cast(Upload.uploadable, list) ::
    {:ok, Upload.t} | {:error, String.t} | :error

  @callback cast_path(Upload.uploadable_path, list) ::
    {:ok, Upload.t} | {:error, String.t} | :error

  @callback transfer(Upload.t) ::
    {:ok, Upload.transferred} | {:error, any}
end
