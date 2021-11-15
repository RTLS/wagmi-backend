defmodule SharedUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :shared_utils,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application, do: [extra_applications: [:logger]]

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def deps do
    [
      {:finch, "~> 0.9.1"},
      {:jason, "~> 1.2"},
      {:proper_case, "~> 1.3.1"}
    ]
  end
end
