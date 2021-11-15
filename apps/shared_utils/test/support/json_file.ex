defmodule SharedUtils.Support.JsonFile do
  @moduledoc "JSON file helpers for testing."

  def load_and_decode(file_name, path \\ ".") do
    "#{path}/#{file_name}"
    |> File.read!()
    |> Jason.decode!()
    |> ProperCase.to_snake_case()
    |> SharedUtils.Enum.atomize_keys()
  end
end
