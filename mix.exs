defmodule OuraRing.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/kalifg/oura_ring_elixir_client"

  def project do
    [
      app: :oura_ring,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      elixirc_paths: elixirc_paths(Mix.env()),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # HTTP client
      {:req, "~> 0.4.0"},

      # JSON parsing
      {:jason, "~> 1.4"},

      # Testing
      {:mox, "~> 1.1", only: :test},
      {:excoveralls, "~> 0.18", only: :test},

      # Documentation
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},

      # Code quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  defp description do
    """
    An Elixir client library for the Oura Ring API v2.
    Access your Oura Ring data including sleep, activity, heart rate,
    readiness, and more with a clean, idiomatic Elixir interface.
    """
  end

  defp package do
    [
      name: "oura_ring",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => @source_url,
        "Oura API Docs" => "https://cloud.ouraring.com/v2/docs"
      },
      maintainers: ["kalifg"]
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "CHANGELOG.md"],
      groups_for_modules: [
        "API Resources": [
          OuraRing.DailySleep,
          OuraRing.DailyActivity,
          OuraRing.DailyReadiness,
          OuraRing.HeartRate,
          OuraRing.Session,
          OuraRing.Tag,
          OuraRing.Workout,
          OuraRing.PersonalInfo
        ]
      ]
    ]
  end
end
