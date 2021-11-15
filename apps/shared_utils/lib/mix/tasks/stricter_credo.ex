defmodule Mix.Tasks.StricterCredo do
  use Mix.Task

  @moduledoc """
  Checks all files that have been changed from master under the "stricter" rules defined in
  .credo.exs. Used to gradually introduce rules into a codebase.

  Run this task manually from apps/shared_utils with `mix stricter_credo` or as part of `mix check`
  """

  @first_args ["credo", "-C", "stricter", "--files-included"]
  @shortdoc "Checks altered files against stricter code quality checks"
  # coveralls-ignore-start

  @impl Mix.Task
  def run(_) do
    with {response, 0} <- git_diff(),
         {:ok, filenames} <- parse_git_diff_output(response),
         {:ok, filtered_files} <- filter_elixir_files(filenames),
         credo_args <- build_credo_args(filtered_files),
         credo_output <- run_credo(credo_args),
         :ok <- parse_credo_output(credo_output) do
      exit_with_message("Run succeeded 👍")
    else
      {:exit, message} -> exit_with_message("Unrecognized git response: #{message}")
      {:error, message} -> exit_with_error(message)
      {message, _} -> exit_with_error(message)
    end
  end

  defp git_diff do
    System.cmd("git", ~w(diff --name-only master...))
  end

  # coveralls-ignore-stop

  def parse_git_diff_output(""), do: {:exit, "No diffs to check 👍"}
  def parse_git_diff_output(string), do: {:ok, String.split(string, ~r/\n/)}

  def filter_elixir_files(file_list) do
    case Enum.filter(file_list, &String.contains?(&1, ".ex")) do
      [] -> {:exit, "No diffs to check 👍"}
      list -> {:ok, list}
    end
  end

  def build_credo_args(files) do
    @first_args ++ Enum.intersperse(files, "--files-included")
  end

  # coveralls-ignore-start
  defp run_credo(args) do
    System.cmd("mix", args, env: [{"MIX_ENV", "test"}], cd: "../..")
  end

  # coveralls-ignore-stop

  def parse_credo_output({output, code}, opts \\ [print: true]) do
    if opts[:print] do
      output
      |> String.split(~r/\n/)
      |> Enum.each(&print/1)
    end

    case code do
      0 -> :ok
      _non_zero -> {:error, "Found errors"}
    end
  end

  # coveralls-ignore-start
  defp print(line) do
    Mix.shell().info(line)
  end

  @spec exit_with_error(String.t()) :: none
  @spec exit_with_error(String.t(), non_neg_integer) :: none
  defp exit_with_error(message, code \\ 1) do
    Mix.shell().error(message)
    System.halt(code)
  end

  defp exit_with_message(message) do
    print(message)
    System.halt(0)
  end

  # coveralls-ignore-stop
end
