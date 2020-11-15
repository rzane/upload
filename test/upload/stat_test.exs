defmodule Upload.StatTest do
  use ExUnit.Case, async: true

  alias Upload.Stat

  @text %Stat{
    byte_size: 9,
    filename: "test.txt",
    content_type: "text/plain",
    path: "test/fixtures/test.txt",
    checksum: "416186c16238c416482d6cce7a4b21d6",
    metadata: nil
  }
  @image %Stat{
    byte_size: 1_124_062,
    filename: "image.jpg",
    content_type: "image/jpeg",
    path: "test/fixtures/image.jpg",
    checksum: "ec68c30cd1106f89b3333b16f8c4b425",
    metadata: %{
      height: 2736,
      width: 4104
    }
  }
  @video %Stat{
    byte_size: 275_433,
    filename: "video.mp4",
    content_type: "video/mp4",
    path: "test/fixtures/video.mp4",
    checksum: "35750acd4787b11851528eaee255cbc3",
    metadata: %{
      display_aspect_ratio: [4, 3],
      duration: 5.166648,
      height: 480.0,
      width: 640.0
    }
  }

  setup do
    on_exit(fn -> configure(false) end)
  end

  describe "with all analyzers enabled" do
    setup do: configure(true)

    test "text.txt" do
      assert Stat.stat(@text.path) == {:ok, @text}
    end

    test "image.jpg" do
      assert Stat.stat(@image.path) == {:ok, @image}
    end

    test "video.mp4" do
      assert Stat.stat(@video.path) == {:ok, @video}
    end
  end

  describe "when analysis is disabled" do
    setup do: configure(false)

    test "metadata is not generated" do
      assert {:ok, stat} = Stat.stat(@image.path)
      refute stat.metadata

      assert {:ok, stat} = Stat.stat(@video.path)
      refute stat.metadata
    end
  end

  describe "when specific analyzers are enabled" do
    setup do: configure([Upload.Stat.Image])

    test "metadata is generated only for those types" do
      assert {:ok, stat} = Stat.stat(@image.path)
      assert stat.metadata

      assert {:ok, stat} = Stat.stat(@video.path)
      refute stat.metadata
    end
  end

  defp configure(analyze) do
    Application.put_env(:upload, :analyze, analyze)
  end
end
