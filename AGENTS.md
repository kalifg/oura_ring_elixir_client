# Guide for LLM Agents

This document provides guidance for Large Language Model (LLM) agents on how to safely and effectively use the Oura Ring Elixir Client library.

## Overview

The Oura Ring Elixir Client is a library for accessing health and fitness data from the Oura Ring API v2. As an AI agent, you should use this library responsibly and follow security best practices.

## Prerequisites

Before using this library, ensure:

1. **API Key is Set**: The `API_KEY` environment variable must be set with a valid Oura API personal access token
2. **User Consent**: Confirm the user wants to access their Oura data
3. **Privacy Understanding**: Understand that this data is personal health information

## API Key Management

### Critical Security Rules

1. **NEVER** hardcode API keys in source code
2. **NEVER** log or display the full API key
3. **NEVER** commit API keys to version control
4. **ALWAYS** use environment variables for API keys
5. **ALWAYS** validate that the API key is set before making requests

### Checking for API Key

Before using any library functions, verify the API key is available:

```elixir
# Good practice
case System.get_env("API_KEY") do
  nil ->
    IO.puts("Error: Please set the API_KEY environment variable")
    :error

  _api_key ->
    # Proceed with API calls
    :ok
end
```

### What NOT to Do

```elixir
# BAD - Never do this!
api_key = "abc123_hardcoded_key"  # NEVER hardcode
IO.puts("Using API key: #{api_key}")  # NEVER log keys
git commit -m "Added API key"  # NEVER commit keys
```

## Using the Library Functions

### Personal Info Endpoint

Use the provided functions rather than constructing HTTP requests manually:

```elixir
# CORRECT - Use library functions
case Oura.Client.get_personal_info() do
  {:ok, data} ->
    # Process data
    IO.puts("Successfully retrieved personal info")

  {:error, :no_api_key} ->
    IO.puts("Please set API_KEY environment variable")

  {:error, reason} ->
    IO.puts("Error: #{inspect(reason)}")
end

# INCORRECT - Don't bypass the library
# Don't construct manual HTTP requests unless absolutely necessary
```

## Data Privacy and Sensitivity

### Health Data is Sensitive

Oura Ring data includes:
- Sleep patterns and quality
- Activity levels and calories
- Heart rate and HRV
- Body temperature
- Personal information (age, weight, height)

### Handling Personal Data

1. **Minimize Data Exposure**: Only retrieve data that's necessary
2. **Don't Store Unnecessarily**: Avoid caching sensitive health data
3. **Respect User Privacy**: Don't share data without explicit consent
4. **Follow Regulations**: Be aware of HIPAA, GDPR, and other privacy laws

### Example: Safe Data Handling

```elixir
# Good - Minimal exposure
case Oura.Client.get_personal_info() do
  {:ok, data} ->
    # Only show what's needed
    IO.puts("Age: #{data["age"]}")

  {:error, reason} ->
    IO.puts("Error occurred")  # Don't expose details unnecessarily
end

# Bad - Over-sharing
case Oura.Client.get_personal_info() do
  {:ok, data} ->
    # Don't dump all personal data
    IO.inspect(data)  # Avoid unless debugging
    File.write("user_data.txt", inspect(data))  # Never write to files

  {:error, _} -> :ok
end
```

## Error Handling

Always handle all possible error cases:

```elixir
case Oura.Client.get_personal_info() do
  {:ok, data} ->
    # Success case
    process_data(data)

  {:error, :no_api_key} ->
    # API key not set
    IO.puts("Error: API_KEY environment variable is required")

  {:error, {:http_error, status_code, body}} ->
    # HTTP error (e.g., 401 Unauthorized, 429 Rate Limit)
    IO.puts("HTTP Error #{status_code}")

  {:error, {:json_parse_error, reason}} ->
    # JSON parsing failed
    IO.puts("Failed to parse response")

  {:error, {:request_failed, reason}} ->
    # Network or connection error
    IO.puts("Request failed: network issue")

  {:error, reason} ->
    # Catch-all for unexpected errors
    IO.puts("Unexpected error occurred")
end
```

## Rate Limiting

The Oura API has rate limits. As an agent:

1. **Don't Make Excessive Requests**: Space out API calls
2. **Handle 429 Errors**: Implement backoff when rate limited
3. **Cache When Appropriate**: Store results temporarily if multiple accesses are needed
4. **Respect API Guidelines**: Follow Oura's terms of service

## Testing

When writing tests or examples:

1. **Use Test Fixtures**: Don't require real API keys for unit tests
2. **Tag Integration Tests**: Mark tests requiring API keys with `@tag :integration`
3. **Mock API Responses**: Use test doubles for predictable testing
4. **Document Test Requirements**: Clearly state when API keys are needed

## Best Practices Summary

### DO:
- ✅ Use environment variables for API keys
- ✅ Use the library's provided functions
- ✅ Handle all error cases
- ✅ Respect user privacy
- ✅ Follow rate limits
- ✅ Validate inputs
- ✅ Use pattern matching for responses

### DON'T:
- ❌ Hardcode API keys
- ❌ Log or display API keys
- ❌ Commit secrets to version control
- ❌ Store sensitive data unnecessarily
- ❌ Make excessive API requests
- ❌ Share user data without consent
- ❌ Ignore error handling

## Example: Complete Safe Implementation

```elixir
defmodule MyOuraApp do
  def fetch_personal_info do
    # 1. Check for API key first
    unless System.get_env("API_KEY") do
      IO.puts("Error: Please set API_KEY environment variable")
      IO.puts("Get your key from: https://cloud.ouraring.com/personal-access-tokens")
      return {:error, :no_api_key}
    end

    # 2. Use library function
    case Oura.Client.get_personal_info() do
      {:ok, data} ->
        # 3. Process minimal data needed
        IO.puts("Personal information retrieved successfully")
        {:ok, data}

      {:error, :no_api_key} ->
        IO.puts("API key not configured")
        {:error, :no_api_key}

      {:error, {:http_error, 401, _}} ->
        IO.puts("Invalid API key - please check your credentials")
        {:error, :unauthorized}

      {:error, {:http_error, 429, _}} ->
        IO.puts("Rate limit exceeded - please try again later")
        {:error, :rate_limited}

      {:error, reason} ->
        IO.puts("Failed to retrieve personal info")
        {:error, reason}
    end
  end
end
```

## Questions or Issues?

If you encounter issues or have questions about using this library safely:

1. Check the README.md for usage examples
2. Review the test files for patterns
3. Consult the Oura API documentation
4. Ask the user for clarification on data handling preferences

## Compliance

When using this library, ensure compliance with:

- Oura API Terms of Service
- GDPR (if handling EU user data)
- HIPAA (if in healthcare context)
- Local privacy regulations
- User consent requirements

Remember: Health data is sensitive. Handle it with care and respect user privacy at all times.
