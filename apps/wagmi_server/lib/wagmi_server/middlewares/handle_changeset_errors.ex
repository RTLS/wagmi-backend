defmodule WagmiServer.Middlewares.HandleChangesetErrors do
  @behaviour Absinthe.Middleware
  def call(resolution, _) do
    %{resolution | errors: Enum.flat_map(resolution.errors, &handle_error/1)}
  end

  defp handle_error(%{code: code, message: %Ecto.Changeset{} = changeset}) do
    [%{code: code, message: handle_error(changeset)}]
  end

  defp handle_error(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.map(fn {k, v} -> "#{k}: #{v}" end)
  end

  defp handle_error(error), do: [error]
end
