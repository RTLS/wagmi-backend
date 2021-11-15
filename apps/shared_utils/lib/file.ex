defmodule SharedUtils.File do
  @moduledoc "Utility functions for files"

  @spec handle_file_error({:ok, any} | {:error, atom}, String.t()) ::
          {:ok, any} | {:error, SharedUtils.Error.t()}
  @doc """
  Handles errors that come out of File

  ### Example

    iex> SharedUtils.File.handle_file_error({:error, :enoent}, "/path")
    {:error, %{code: :not_found, details: %{file_path: "/path"}, message: "file not found"}}
  """
  def handle_file_error({:ok, _} = file_res, _file_path) do
    file_res
  end

  def handle_file_error({:error, error}, file_path) when is_atom(error) do
    {:error, translate_error(error, file_path)}
  end

  def handle_file_error(e, _) do
    e
  end

  defp translate_error(:enoent, file_path) do
    SharedUtils.Error.not_found(
      "file not found",
      %{file_path: file_path}
    )
  end

  defp translate_error(:eacces, file_path) do
    SharedUtils.Error.forbidden(
      "permissions not high enough to read file",
      %{file_path: file_path}
    )
  end

  defp translate_error(:eisdir, file_path) do
    SharedUtils.Error.bad_request(
      "file path given is a directory",
      %{file_path: file_path}
    )
  end

  defp translate_error(:enotdir, file_path) do
    SharedUtils.Error.bad_request(
      "file path given is not a directory",
      %{file_path: file_path}
    )
  end

  defp translate_error(:enomem, file_path) do
    SharedUtils.Error.internal_server_error(
      "not enough memory to read file",
      %{file_path: file_path}
    )
  end

  @doc """
  Does a deep recursive ls of a folder
  """
  def deep_ls(path) do
    cond do
      File.regular?(path) ->
        [path]

      File.dir?(path) ->
        path
        |> File.ls!()
        |> Stream.map(&Path.join(path, &1))
        |> Stream.map(&deep_ls/1)
        |> Enum.concat()

      true ->
        []
    end
  end

  @doc """
  Does a deep recursive ls of a folder and returns relative results
  """
  def deep_relative_ls(path) do
    path_replacer = if String.ends_with?(path, "/"), do: path, else: "#{path}/"

    path
    |> deep_ls
    |> Enum.map(&String.replace(&1, path_replacer, ""))
  end
end
