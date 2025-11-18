defmodule OuraRing do
  @moduledoc """
  OuraRing is an Elixir client library for the Oura Ring API v2.

  This library provides access to your Oura Ring health and activity data including:
  - Daily sleep analysis
  - Daily activity metrics
  - Daily readiness scores
  - Heart rate data
  - Workout and session tracking
  - Personal information
  - And more

  ## Installation

  Add `oura_ring` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:oura_ring, "~> 0.1.0"}
    ]
  end
  ```

  ## Configuration

  You can configure your Oura Personal Access Token in your config files:

  ```elixir
  config :oura_ring,
    access_token: System.get_env("OURA_PERSONAL_ACCESS_TOKEN")
  ```

  Or pass it directly when making requests:

  ```elixir
  OuraRing.DailySleep.list(
    access_token: "YOUR_TOKEN",
    start_date: ~D[2025-01-01],
    end_date: ~D[2025-01-07]
  )
  ```

  ## Basic Usage

  ```elixir
  # Get your personal information
  {:ok, info} = OuraRing.PersonalInfo.get(access_token: token)

  # Get daily sleep data for a date range
  {:ok, sleep_data} = OuraRing.DailySleep.list(
    access_token: token,
    start_date: ~D[2025-01-01],
    end_date: ~D[2025-01-07]
  )

  # Get heart rate data for the last 24 hours
  {:ok, heart_rate} = OuraRing.HeartRate.list(
    access_token: token,
    start_datetime: DateTime.add(DateTime.utc_now(), -86400, :second),
    end_datetime: DateTime.utc_now()
  )
  ```

  ## Authentication

  The Oura API uses Personal Access Tokens for authentication. You can generate
  a token at: https://cloud.ouraring.com/personal-access-tokens

  **Note:** Personal Access Tokens will be deprecated by the end of 2025. OAuth2
  support will be added in a future version of this library.

  ## API Resources

  - `OuraRing.DailySleep` - Daily sleep periods and analysis
  - `OuraRing.DailyActivity` - Daily activity summaries
  - `OuraRing.DailyReadiness` - Daily readiness scores
  - `OuraRing.DailyStress` - Daily stress and recovery data
  - `OuraRing.DailySpO2` - Blood oxygen levels (Gen 3+ only)
  - `OuraRing.HeartRate` - Heart rate samples (5-minute intervals)
  - `OuraRing.Session` - Guided and unguided sessions
  - `OuraRing.Workout` - Workout and exercise data
  - `OuraRing.Tag` - User tags and enhanced tags
  - `OuraRing.PersonalInfo` - User demographic information
  - `OuraRing.SleepTime` - Ideal bedtime recommendations
  - `OuraRing.RestModePeriod` - Rest mode tracking
  - `OuraRing.RingConfiguration` - Ring hardware details

  ## Error Handling

  All API functions return `{:ok, result}` or `{:error, reason}` tuples.

  Common error reasons:
  - `:unauthorized` - Invalid or missing access token
  - `:not_found` - Resource not found
  - `:rate_limited` - API rate limit exceeded
  - `{:http_error, status, body}` - Other HTTP errors

  ## Rate Limiting

  The Oura API has rate limits. This library does not currently implement
  automatic rate limiting or retry logic. Consider implementing backoff
  strategies in your application code.
  """

  @doc """
  Returns the version of the OuraRing library.

  ## Examples

      iex> OuraRing.version()
      "0.1.0"
  """
  @spec version() :: String.t()
  def version do
    Application.spec(:oura_ring, :vsn) |> to_string()
  end

  @doc """
  Returns the base URL for the Oura API.

  Can be overridden via configuration:

      config :oura_ring, base_url: "https://api.ouraring.com"

  ## Examples

      iex> OuraRing.base_url()
      "https://api.ouraring.com"
  """
  @spec base_url() :: String.t()
  def base_url do
    Application.get_env(:oura_ring, :base_url, "https://api.ouraring.com")
  end

  @doc """
  Returns the configured access token, if any.

  ## Examples

      iex> OuraRing.access_token()
      "YOUR_TOKEN_HERE"
  """
  @spec access_token() :: String.t() | nil
  def access_token do
    Application.get_env(:oura_ring, :access_token)
  end
end
