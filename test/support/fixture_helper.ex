defmodule OuraRing.FixtureHelper do
  @moduledoc """
  Helper module for loading test fixtures.
  """

  @fixtures_path "test/fixtures"

  @doc """
  Loads a JSON fixture file and decodes it.

  ## Examples

      iex> load_fixture("daily_sleep.json")
      %{"data" => [...], "next_token" => nil}
  """
  def load_fixture(filename) do
    Path.join(@fixtures_path, filename)
    |> File.read!()
    |> Jason.decode!()
  end

  @doc """
  Creates a mock Req response.
  """
  def mock_response(status, body) do
    %Req.Response{
      status: status,
      body: body,
      headers: []
    }
  end

  @doc """
  Creates a successful mock response with fixture data.
  """
  def success_response(fixture_file) do
    body = load_fixture(fixture_file)
    mock_response(200, body)
  end
end
