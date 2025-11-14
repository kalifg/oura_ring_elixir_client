defmodule OuraRingElixirClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :oura_ring_elixir_client,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Using built-in :httpc and :json for now due to Hex.pm connectivity issues
      # In production, use: {:httpoison, "~> 2.0"}, {:jason, "~> 1.4"}
    ]
  end
end
