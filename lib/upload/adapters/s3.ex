if Code.ensure_loaded?(ExAws.S3) do
  defmodule Upload.Adapters.S3 do
    @moduledoc """
    An `Upload.Adapter` that stores files using Amazon S3.

    ### Requirements

        def deps do
          [{:ex_aws_s3, "~> 2.0"},
           {:hackney, ">= 0.0.0"},
           {:sweet_xml, ">= 0.0.0"}]
        end

    ### Configuration

        config :upload, Upload.Adapters.S3,
          bucket: "mybucket", # required
          base_url: "https://mybucket.s3.amazonaws.com" # optional

    """

    use Upload.Adapter
    alias Upload.Config

    @doc """
    The bucket that was configured.

    ## Examples

        iex> Upload.Adapters.S3.bucket()
        "my_bucket_name"

    """
    def bucket, do: Config.fetch!(__MODULE__, :bucket)

    @doc """
    The base URL that all resources are hosted on.

    ## Examples

        iex> Upload.Adapters.S3.base_url()
        "https://my_bucket_name.s3.amazonaws.com"

    """
    def base_url do
      Config.get(__MODULE__, :base_url, "https://#{bucket()}.s3.amazonaws.com")
    end

    @impl true
    def get_url(key) do
      base_url()
      |> URI.merge(key)
      |> URI.to_string()
    end

    @impl true
    @spec get_signed_url(String.t(), ExAws.S3.presigned_url_opts()) ::
            {:ok, String.t()} | {:error, String.t()}
    def get_signed_url(key, opts) do
      :s3
      |> ExAws.Config.new()
      |> ExAws.S3.presigned_url(:get, bucket(), key, opts)
    end

    @impl true
    def transfer(%Upload{key: key, path: path} = upload) do
      case put_object(key, path) do
        {:ok, _} ->
          {:ok, %Upload{upload | status: :transferred}}

        _ ->
          {:error, "failed to transfer file"}
      end
    end

    defp put_object(key, path) do
      path
      |> ExAws.S3.Upload.stream_file()
      |> ExAws.S3.upload(bucket(), key)
      |> ExAws.request()
    end
  end
end
