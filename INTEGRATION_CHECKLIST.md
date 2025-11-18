# Integration Checklist

This document provides step-by-step instructions for manually testing the OuraRing Elixir client library with real API calls.

## Prerequisites

Before you begin, ensure you have:

- [x] Elixir 1.14 or later installed
- [x] An Oura Ring account
- [x] An active Oura Membership (required for API access as of 2025)
- [ ] A Personal Access Token from Oura

## Step 1: Get Your Personal Access Token

1. Visit https://cloud.ouraring.com/personal-access-tokens
2. Log in with your Oura account credentials
3. Click "Create New Personal Access Token"
4. Give your token a descriptive name (e.g., "Elixir Client Testing")
5. Copy the generated token (you won't be able to see it again!)
6. Store it securely

**Important**: Personal Access Tokens will be deprecated by the end of 2025. This library will be updated to support OAuth2 authentication before that deadline.

## Step 2: Set Your Access Token

### Option A: Environment Variable (Recommended)

```bash
export OURA_PERSONAL_ACCESS_TOKEN="your_token_here"
```

To make it permanent, add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
echo 'export OURA_PERSONAL_ACCESS_TOKEN="your_token_here"' >> ~/.bashrc
source ~/.bashrc
```

### Option B: Configuration File

Create or edit `config/dev.secret.exs` (this file is gitignored):

```elixir
import Config

config :oura_ring,
  access_token: "your_token_here"
```

## Step 3: Install Dependencies

```bash
cd oura_ring_elixir_client
mix deps.get
```

Expected output:
```
Resolving Hex dependencies...
Resolution completed in 0.XXX s
New:
  req 0.4.x
  jason 1.4.x
  ...
* Getting req (Hex package)
* Getting jason (Hex package)
...
```

## Step 4: Verify Installation

```bash
mix compile
```

Expected output:
```
Compiling X files (.ex)
Generated oura_ring app
```

## Step 5: Run Basic Tests

```bash
mix test
```

Expected output:
```
...
Finished in X.XX seconds (X.XXs async, X.XXs sync)
XX tests, 0 failures
```

Note: Unit tests use fixtures and don't require API access.

## Step 6: Manual Integration Testing

### Test 1: Verify Token and Get Personal Info

Create a test script `test_integration.exs`:

```elixir
# test_integration.exs
token = System.get_env("OURA_PERSONAL_ACCESS_TOKEN") ||
        Application.get_env(:oura_ring, :access_token)

if !token do
  IO.puts("ERROR: OURA_PERSONAL_ACCESS_TOKEN not set!")
  System.halt(1)
end

IO.puts("✓ Token found: #{String.slice(token, 0..10)}...")

# Test 1: Get Personal Info
IO.puts("\nTest 1: Getting Personal Info...")
case OuraRing.PersonalInfo.get(access_token: token) do
  {:ok, info} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Email: #{info["email"]}")
    IO.puts("  Age: #{info["age"]}")
    IO.puts("  Height: #{info["height"]}m")
    IO.puts("  Weight: #{info["weight"]}kg")

  {:error, :unauthorized} ->
    IO.puts("✗ FAILED: Unauthorized - check your token")
    System.halt(1)

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end
```

Run it:

```bash
mix run test_integration.exs
```

Expected output:
```
✓ Token found: ABCDEFGHIJK...

Test 1: Getting Personal Info...
✓ SUCCESS!
  Email: your@email.com
  Age: 30
  Height: 1.75m
  Weight: 70.5kg
```

### Test 2: Get Sleep Data

Add to `test_integration.exs`:

```elixir
# Test 2: Get Recent Sleep Data
IO.puts("\nTest 2: Getting Sleep Data (Last 7 Days)...")
start_date = Date.add(Date.utc_today(), -7)
end_date = Date.utc_today()

case OuraRing.DailySleep.list(
  access_token: token,
  start_date: start_date,
  end_date: end_date
) do
  {:ok, sleep_data} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Retrieved #{length(sleep_data)} sleep records")

    if length(sleep_data) > 0 do
      latest = hd(sleep_data)
      IO.puts("  Latest:")
      IO.puts("    Date: #{latest["day"]}")
      IO.puts("    Score: #{latest["score"]}")
      IO.puts("    Deep Sleep Contributor: #{latest["contributors"]["deep_sleep"]}")
    end

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end
```

Expected output:
```
Test 2: Getting Sleep Data (Last 7 Days)...
✓ SUCCESS!
  Retrieved 7 sleep records
  Latest:
    Date: 2025-01-17
    Score: 85
    Deep Sleep Contributor: 88
```

### Test 3: Get Activity Data

Add to `test_integration.exs`:

```elixir
# Test 3: Get Recent Activity Data
IO.puts("\nTest 3: Getting Activity Data (Last 3 Days)...")
start_date = Date.add(Date.utc_today(), -3)

case OuraRing.DailyActivity.list(
  access_token: token,
  start_date: start_date,
  end_date: Date.utc_today()
) do
  {:ok, activity_data} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Retrieved #{length(activity_data)} activity records")

    if length(activity_data) > 0 do
      latest = hd(activity_data)
      IO.puts("  Latest:")
      IO.puts("    Date: #{latest["day"]}")
      IO.puts("    Score: #{latest["score"]}")
      IO.puts("    Steps: #{latest["steps"]}")
      IO.puts("    Calories: #{latest["active_calories"]}")
    end

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end
```

Expected output:
```
Test 3: Getting Activity Data (Last 3 Days)...
✓ SUCCESS!
  Retrieved 3 activity records
  Latest:
    Date: 2025-01-17
    Score: 82
    Steps: 8542
    Calories: 425
```

### Test 4: Get Readiness Data

Add to `test_integration.exs`:

```elixir
# Test 4: Get Readiness Data
IO.puts("\nTest 4: Getting Readiness Data...")

case OuraRing.DailyReadiness.list(
  access_token: token,
  start_date: Date.add(Date.utc_today(), -1),
  end_date: Date.utc_today()
) do
  {:ok, [readiness | _]} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Date: #{readiness["day"]}")
    IO.puts("  Score: #{readiness["score"]}")
    IO.puts("  Temperature Deviation: #{readiness["temperature_deviation"]}°C")
    IO.puts("  HRV Balance: #{readiness["contributors"]["hrv_balance"]}")

  {:ok, []} ->
    IO.puts("⚠ No readiness data available (this is normal if you haven't worn your ring recently)")

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end
```

### Test 5: Get Heart Rate Data

Add to `test_integration.exs`:

```elixir
# Test 5: Get Heart Rate Data (Last 6 Hours)
IO.puts("\nTest 5: Getting Heart Rate Data...")
start_time = DateTime.add(DateTime.utc_now(), -21600, :second)  # 6 hours ago
end_time = DateTime.utc_now()

case OuraRing.HeartRate.list(
  access_token: token,
  start_datetime: start_time,
  end_datetime: end_time
) do
  {:ok, hr_data} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Retrieved #{length(hr_data)} heart rate samples")

    if length(hr_data) > 0 do
      latest = hd(hr_data)
      IO.puts("  Latest sample:")
      IO.puts("    BPM: #{latest["bpm"]}")
      IO.puts("    Source: #{latest["source"]}")
      IO.puts("    Time: #{latest["timestamp"]}")
    end

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end
```

### Test 6: Test Pagination

Add to `test_integration.exs`:

```elixir
# Test 6: Test Pagination (Get 30 Days of Sleep Data)
IO.puts("\nTest 6: Testing Pagination (30 Days of Sleep)...")
start_date = Date.add(Date.utc_today(), -30)

case OuraRing.DailySleep.list(
  access_token: token,
  start_date: start_date,
  end_date: Date.utc_today()
) do
  {:ok, sleep_data} ->
    IO.puts("✓ SUCCESS!")
    IO.puts("  Retrieved #{length(sleep_data)} records (pagination handled automatically)")

  {:error, reason} ->
    IO.puts("✗ FAILED: #{inspect(reason)}")
    System.halt(1)
end

IO.puts("\n" <> String.duplicate("=", 60))
IO.puts("All integration tests completed successfully! ✓")
IO.puts(String.duplicate("=", 60))
```

## Step 7: Run the HealthWatch Example

Create the HealthWatch example from the README:

```bash
# Copy the HealthWatch example from README.md to health_watch.exs
# Then run:
mix run health_watch.exs
```

Expected output:
```
=== Oura Ring Health Watch ===

User: your@email.com
Age: 30, Height: 1.75m, Weight: 70.5kg

Sleep Data (Last 7 Days):
============================================================

Date: 2025-01-17
  Overall Score: 85
  Contributors:
    Deep Sleep:   88
    REM Sleep:    90
    Total Sleep:  82
    ...

Average Sleep Score: 84.3

============================================================
Latest Readiness:

Readiness Score: 86
Contributors:
  Activity Balance:     88
  Body Temperature:     92
  ...
```

## Step 8: Test Error Handling

Create `test_errors.exs`:

```elixir
# Test with invalid token
IO.puts("Testing error handling with invalid token...")

case OuraRing.PersonalInfo.get(access_token: "invalid_token_123") do
  {:error, :unauthorized} ->
    IO.puts("✓ Correctly handles unauthorized error")

  other ->
    IO.puts("✗ Unexpected result: #{inspect(other)}")
end

# Test with missing token
IO.puts("\nTesting error handling with missing token...")

try do
  OuraRing.PersonalInfo.get()
  IO.puts("✗ Should have raised KeyError")
rescue
  KeyError ->
    IO.puts("✓ Correctly raises KeyError for missing token")
end
```

Run it:

```bash
mix run test_errors.exs
```

## Common Issues and Solutions

### Issue: "Unauthorized" Error

**Cause**: Invalid or expired token

**Solution**:
1. Verify your token at https://cloud.ouraring.com/personal-access-tokens
2. Ensure the token is correctly set in your environment
3. Generate a new token if needed

### Issue: "Rate Limited" Error

**Cause**: Too many API requests in a short time

**Solution**:
1. Implement delays between requests
2. Use exponential backoff for retries
3. Cache results when possible

### Issue: Empty Data Arrays

**Cause**: No data available for the requested date range

**Solution**:
1. Verify you've worn your Oura Ring during the requested period
2. Wait for data to sync (can take several hours)
3. Check your Oura Membership is active

### Issue: Missing SpO2 or Stress Data

**Cause**: Feature not available on your ring generation

**Solution**:
- SpO2 requires Gen 3 or later
- Stress requires compatible ring generation
- Check your ring model in the Oura app

## Checklist Summary

- [ ] Personal Access Token obtained and configured
- [ ] Dependencies installed (`mix deps.get`)
- [ ] Code compiled successfully (`mix compile`)
- [ ] Unit tests pass (`mix test`)
- [ ] Personal Info retrieval works
- [ ] Sleep data retrieval works
- [ ] Activity data retrieval works
- [ ] Readiness data retrieval works
- [ ] Heart Rate data retrieval works
- [ ] Pagination works for large datasets
- [ ] HealthWatch example runs successfully
- [ ] Error handling works correctly
- [ ] All API endpoints tested

## Next Steps

Once all integration tests pass:

1. Review the code for any project-specific customizations needed
2. Add your own business logic on top of the client
3. Implement rate limiting if making frequent requests
4. Consider adding telemetry for monitoring
5. Deploy your application!

## Support

If you encounter issues:

1. Check the [README.md](README.md) for examples
2. Review the [SUMMARY.md](SUMMARY.md) for design decisions
3. Consult the [Oura API Documentation](https://cloud.ouraring.com/v2/docs)
4. Open an issue on GitHub with:
   - Your Elixir version
   - Error messages (redact your token!)
   - Steps to reproduce
