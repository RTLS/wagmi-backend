defmodule SharedUtils.FileTest do
  use ExUnit.Case, async: true

  doctest SharedUtils.File

  setup do
    root_dir = "#{:code.priv_dir(:shared_utils)}/file_test"

    File.mkdir_p!("#{root_dir}/folder/second")

    File.write!("#{root_dir}/file.json", "empty")
    File.write!("#{root_dir}/folder/file.json", "empty")
    File.write!("#{root_dir}/folder/second/file.json", "empty")

    on_exit(fn ->
      File.rm_rf!(root_dir)
    end)

    %{root_dir: root_dir}
  end

  describe "&deep_ls/1" do
    test "returns files nested in folders", %{root_dir: root_dir} do
      expected =
        Enum.map(
          [
            "folder/second/file.json",
            "folder/file.json",
            "file.json"
          ],
          &Path.join(root_dir, &1)
        )

      assert Enum.sort(expected) === Enum.sort(SharedUtils.File.deep_ls(root_dir))
    end
  end

  describe "&deep_relative_ls/1" do
    test "returns files nested in folders without the absolute path", %{root_dir: root_dir} do
      expected = [
        "folder/second/file.json",
        "folder/file.json",
        "file.json"
      ]

      assert Enum.sort(expected) === Enum.sort(SharedUtils.File.deep_relative_ls(root_dir))
    end

    test "returns proper results when root_dir ends with a /", %{root_dir: root_dir} do
      expected = [
        "folder/second/file.json",
        "folder/file.json",
        "file.json"
      ]

      assert Enum.sort(expected) === Enum.sort(SharedUtils.File.deep_relative_ls("#{root_dir}/"))
    end
  end
end
