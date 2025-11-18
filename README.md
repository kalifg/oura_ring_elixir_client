# OuraRing

[![Hex.pm](https://img.shields.io/hexpm/v/oura_ring.svg)](https://hex.pm/packages/oura_ring)
[![Documentation](https://img.shields.io/badge/docs-hexdocs-blue.svg)](https://hexdocs.pm/oura_ring)
[![License](https://img.shields.io/hexpm/l/oura_ring.svg)](LICENSE)

An Elixir client library for the [Oura Ring API v2](https://cloud.ouraring.com/v2/docs). Access your Oura Ring health and activity data with a clean, idiomatic Elixir interface.

## Features

- **Complete API v2 Coverage**: Access all Oura Ring data types including sleep, activity, readiness, heart rate, workouts, and more
- **Idiomatic Elixir**: Clean, functional API with pattern matching and error tuples
- **Type Specs**: Full type specifications for better IDE support and documentation
- **Pagination Support**: Automatic pagination handling for large datasets
- **Comprehensive Documentation**: Detailed moduledocs and examples for every function
- **Test Fixtures**: Included test fixtures for offline development and testing

## Supported Data Types

- **Daily Metrics**: Sleep, Activity, Readiness, Stress, SpO2
- **Intraday Data**: Heart Rate (5-minute intervals)
- **Activities**: Workouts, Sessions (meditation, breathing)
- **User Data**: Personal Info, Ring Configuration
- **Tracking**: Tags, Rest Mode Periods, Sleep Time Recommendations

## Installation

Add `oura_ring` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:oura_ring, "~> 0.1.0"}
  ]
end
```

Then run:

```bash
mix deps.get
```

## Configuration

### Personal Access Token

You'll need a Personal Access Token from Oura. Get one at: https://cloud.ouraring.com/personal-access-tokens

**Important**: Personal Access Tokens will be deprecated by the end of 2025. OAuth2 support will be added in a future version.

### Option 1: Environment Variable (Recommended)

```bash
export OURA_PERSONAL_ACCESS_TOKEN="your_token_here"
```

Then configure in `config/config.exs`:

```elixir
config :oura_ring,
  access_token: System.get_env("OURA_PERSONAL_ACCESS_TOKEN")
```

### Option 2: Direct Configuration

```elixir
config :oura_ring,
  access_token: "your_token_here"
```

### Option 3: Pass Token Directly

You can also pass the token directly to each function call:

```elixir
OuraRing.DailySleep.list(access_token: "your_token_here")
```

## Quick Start

```elixir
# Get your personal information
{:ok, info} = OuraRing.PersonalInfo.get(access_token: token)
IO.puts("Age: #{info["age"]}")

# Get sleep data for the last 7 days
{:ok, sleep_data} = OuraRing.DailySleep.list(
  access_token: token,
  start_date: Date.add(Date.utc_today(), -7),
  end_date: Date.utc_today()
)

Enum.each(sleep_data, fn sleep ->
  IO.puts("#{sleep["day"]}: Score #{sleep["score"]}")
end)

# Get heart rate data for the last 24 hours
{:ok, heart_rate} = OuraRing.HeartRate.list(
  access_token: token,
  start_datetime: DateTime.add(DateTime.utc_now(), -86400, :second),
  end_datetime: DateTime.utc_now()
)

# Get daily activity
{:ok, activity} = OuraRing.DailyActivity.list(
  access_token: token,
  start_date: ~D[2025-01-01],
  end_date: ~D[2025-01-07]
)

# Get readiness scores
{:ok, readiness} = OuraRing.DailyReadiness.list(
  access_token: token,
  start_date: ~D[2025-01-01]
)
```

## HealthWatch Example

Here's a complete example that polls Oura data and displays sleep metrics (similar to a health monitoring dashboard):

```elixir
defmodule HealthWatch do
  @moduledoc """
  A simple health monitoring tool that polls Oura Ring data
  and displays sleep metrics.
  """

  def run do
    token = System.get_env("OURA_PERSONAL_ACCESS_TOKEN") ||
            Application.get_env(:oura_ring, :access_token)

    unless token do
      IO.puts("Error: OURA_PERSONAL_ACCESS_TOKEN not set")
      System.halt(1)
    end

    IO.puts("\n=== Oura Ring Health Watch ===\n")

    # Get personal info
    case OuraRing.PersonalInfo.get(access_token: token) do
      {:ok, info} ->
        IO.puts("User: #{info["email"]}")
        IO.puts("Age: #{info["age"]}, Height: #{info["height"]}m, Weight: #{info["weight"]}kg\n")

      {:error, reason} ->
        IO.puts("Error fetching personal info: #{inspect(reason)}")
    end

    # Get last 7 days of sleep data
    start_date = Date.add(Date.utc_today(), -7)
    end_date = Date.utc_today()

    IO.puts("Sleep Data (Last 7 Days):")
    IO.puts("#{String.duplicate("=", 60)}\n")

    case OuraRing.DailySleep.list(
      access_token: token,
      start_date: start_date,
      end_date: end_date
    ) do
      {:ok, sleep_data} ->
        sleep_data
        |> Enum.sort_by(& &1["day"], :desc)
        |> Enum.each(&display_sleep_summary/1)

        # Calculate average sleep score
        if length(sleep_data) > 0 do
          avg_score =
            sleep_data
            |> Enum.map(& &1["score"])
            |> Enum.filter(&is_number/1)
            |> then(fn scores ->
              if Enum.empty?(scores), do: 0, else: Enum.sum(scores) / length(scores)
            end)
            |> Float.round(1)

          IO.puts("\nAverage Sleep Score: #{avg_score}")
        end

      {:error, reason} ->
        IO.puts("Error fetching sleep data: #{inspect(reason)}")
    end

    # Get latest readiness score
    IO.puts("\n#{String.duplicate("=", 60)}")
    IO.puts("Latest Readiness:\n")

    case OuraRing.DailyReadiness.list(
      access_token: token,
      start_date: Date.add(Date.utc_today(), -1),
      end_date: Date.utc_today()
    ) do
      {:ok, [readiness | _]} ->
        display_readiness(readiness)

      {:ok, []} ->
        IO.puts("No readiness data available")

      {:error, reason} ->
        IO.puts("Error fetching readiness: #{inspect(reason)}")
    end
  end

  defp display_sleep_summary(sleep) do
    day = sleep["day"]
    score = sleep["score"] || "N/A"
    contributors = sleep["contributors"] || %{}

    deep_sleep = contributors["deep_sleep"] || "N/A"
    efficiency = contributors["efficiency"] || "N/A"
    latency = contributors["latency"] || "N/A"
    rem_sleep = contributors["rem_sleep"] || "N/A"
    restfulness = contributors["restfulness"] || "N/A"
    timing = contributors["timing"] || "N/A"
    total_sleep = contributors["total_sleep"] || "N/A"

    IO.puts("Date: #{day}")
    IO.puts("  Overall Score: #{score}")
    IO.puts("  Contributors:")
    IO.puts("    Deep Sleep:   #{deep_sleep}")
    IO.puts("    REM Sleep:    #{rem_sleep}")
    IO.puts("    Total Sleep:  #{total_sleep}")
    IO.puts("    Efficiency:   #{efficiency}")
    IO.puts("    Latency:      #{latency}")
    IO.puts("    Restfulness:  #{restfulness}")
    IO.puts("    Timing:       #{timing}")
    IO.puts("")
  end

  defp display_readiness(readiness) do
    score = readiness["score"] || "N/A"
    contributors = readiness["contributors"] || %{}

    IO.puts("Readiness Score: #{score}")
    IO.puts("Contributors:")
    IO.puts("  Activity Balance:     #{contributors["activity_balance"] || "N/A"}")
    IO.puts("  Body Temperature:     #{contributors["body_temperature"] || "N/A"}")
    IO.puts("  HRV Balance:          #{contributors["hrv_balance"] || "N/A"}")
    IO.puts("  Previous Day Activity: #{contributors["previous_day_activity"] || "N/A"}")
    IO.puts("  Previous Night Sleep:  #{contributors["previous_night_sleep"] || "N/A"}")
    IO.puts("  Recovery Index:       #{contributors["recovery_index"] || "N/A"}")
    IO.puts("  Resting Heart Rate:   #{contributors["resting_heart_rate"] || "N/A"}")
    IO.puts("  Sleep Balance:        #{contributors["sleep_balance"] || "N/A"}")
  end
end

# Run the health watch
HealthWatch.run()
```

To run this example:

```bash
export OURA_PERSONAL_ACCESS_TOKEN="your_token"
elixir health_watch.exs
```

## API Reference

### Daily Metrics

- `OuraRing.DailySleep` - Daily sleep periods and analysis
- `OuraRing.DailyActivity` - Daily activity summaries
- `OuraRing.DailyReadiness` - Daily readiness scores
- `OuraRing.DailyStress` - Daily stress and recovery data
- `OuraRing.DailySpO2` - Blood oxygen levels (Gen 3+ only)

### Intraday Data

- `OuraRing.HeartRate` - Heart rate samples (5-minute intervals)

### Activities

- `OuraRing.Workout` - Workout and exercise data
- `OuraRing.Session` - Guided and unguided sessions (meditation, breathing)

### User Information

- `OuraRing.PersonalInfo` - User demographic information
- `OuraRing.RingConfiguration` - Ring hardware details

### Tracking & Tags

- `OuraRing.Tag` - User tags (enhanced and legacy)
- `OuraRing.SleepTime` - Ideal bedtime recommendations
- `OuraRing.RestModePeriod` - Rest mode tracking

## Error Handling

All API functions return `{:ok, result}` or `{:error, reason}` tuples:

```elixir
case OuraRing.DailySleep.list(access_token: token) do
  {:ok, sleep_data} ->
    # Process sleep data
    IO.inspect(sleep_data)

  {:error, :unauthorized} ->
    IO.puts("Invalid access token")

  {:error, :not_found} ->
    IO.puts("Resource not found")

  {:error, :rate_limited} ->
    IO.puts("Rate limit exceeded")

  {:error, {:http_error, status, body}} ->
    IO.puts("HTTP error #{status}: #{inspect(body)}")

  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end
```

## Rate Limiting

The Oura API has rate limits. This library does not currently implement automatic rate limiting or retry logic. Consider implementing exponential backoff in your application code if you're making frequent requests.

## Development

```bash
# Clone the repository
git clone https://github.com/kalifg/oura_ring_elixir_client.git
cd oura_ring_elixir_client

# Install dependencies
mix deps.get

# Run tests
mix test

# Generate documentation
mix docs

# Check code quality
mix credo

# Format code
mix format
```

## Testing

The library includes comprehensive test fixtures for offline development. See `test/fixtures/` for sample API responses.

```bash
# Run all tests
mix test

# Run with coverage
mix coveralls

# Run specific test file
mix test test/oura_ring/daily_sleep_test.exs
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `mix format` and `mix credo`
5. Submit a pull request

## License

Copyright 2025 kalifg

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Resources

- [Oura API Documentation](https://cloud.ouraring.com/v2/docs)
- [Oura Ring Official Site](https://ouraring.com)
- [Get Your Personal Access Token](https://cloud.ouraring.com/personal-access-tokens)
- [Hex Package](https://hex.pm/packages/oura_ring)
- [Documentation](https://hexdocs.pm/oura_ring)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

## Acknowledgments

This library is a port of the Python [oura-ring](https://github.com/hedgertronic/oura-ring) library to Elixir, adapted with idiomatic Elixir patterns and OTP conventions.
