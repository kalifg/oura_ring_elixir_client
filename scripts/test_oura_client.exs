#!/usr/bin/env elixir

# Test script for Oura Ring Elixir Client
# Usage: mix run scripts/test_oura_client.exs
#
# Requires: API_KEY environment variable to be set
# Example: API_KEY="your_token" mix run scripts/test_oura_client.exs

defmodule OuraClientTester do
  @moduledoc """
  Test script to verify Oura Client functionality with a real API key.
  """

  def run do
    IO.puts("\n=== Oura Ring Elixir Client Test Script ===\n")

    # Check if API key is set
    case System.get_env("API_KEY") do
      nil ->
        print_api_key_error()
        System.halt(1)

      api_key ->
        IO.puts("✓ API_KEY environment variable is set")
        IO.puts("  Key prefix: #{String.slice(api_key, 0..7)}...")
        run_tests()
    end
  end

  defp print_api_key_error do
    IO.puts("""
    ✗ Error: API_KEY environment variable is not set

    To use this script, you need to set your Oura API personal access token:

      export API_KEY="your_oura_api_token"

    Or run this script with:

      API_KEY="your_token" mix run scripts/test_oura_client.exs

    You can get your API key from:
      https://cloud.ouraring.com/personal-access-tokens
    """)
  end

  defp run_tests do
    IO.puts("\n--- Testing get_personal_info/0 ---\n")

    case Oura.Client.get_personal_info() do
      {:ok, data} ->
        IO.puts("✓ Successfully retrieved personal information\n")
        print_personal_info(data)

      {:error, :no_api_key} ->
        IO.puts("✗ Error: API key not set (unexpected)")
        System.halt(1)

      {:error, {:http_error, 401, _body}} ->
        IO.puts("✗ Error: Invalid API key (401 Unauthorized)")
        IO.puts("  Please check that your API_KEY is correct")
        System.halt(1)

      {:error, {:http_error, 429, _body}} ->
        IO.puts("✗ Error: Rate limit exceeded (429 Too Many Requests)")
        IO.puts("  Please wait a moment and try again")
        System.halt(1)

      {:error, {:http_error, status_code, body}} ->
        IO.puts("✗ HTTP Error #{status_code}")
        IO.puts("  Response: #{String.slice(to_string(body), 0..200)}")
        System.halt(1)

      {:error, {:json_parse_error, reason}} ->
        IO.puts("✗ JSON Parse Error")
        IO.puts("  Reason: #{inspect(reason)}")
        System.halt(1)

      {:error, {:request_failed, reason}} ->
        IO.puts("✗ Request Failed")
        IO.puts("  Reason: #{inspect(reason)}")
        System.halt(1)

      {:error, reason} ->
        IO.puts("✗ Unexpected Error")
        IO.puts("  Reason: #{inspect(reason)}")
        System.halt(1)
    end

    IO.puts("\n=== All tests completed successfully! ===\n")
  end

  defp print_personal_info(data) when is_map(data) do
    IO.puts("Personal Information:")
    IO.puts("--------------------")

    # Print each field if it exists
    fields = [
      {"Age", "age"},
      {"Weight", "weight"},
      {"Height", "height"},
      {"Biological Sex", "biological_sex"},
      {"Email", "email"}
    ]

    Enum.each(fields, fn {label, key} ->
      case Map.get(data, key) do
        nil ->
          :ok

        value ->
          # Partially redact email for privacy
          display_value =
            if key == "email" do
              redact_email(value)
            else
              value
            end

          IO.puts("  #{label}: #{display_value}")
      end
    end)

    # Show any additional fields
    known_keys = Enum.map(fields, fn {_, key} -> key end)
    other_keys = Map.keys(data) -- known_keys

    if length(other_keys) > 0 do
      IO.puts("\n  Additional fields:")

      Enum.each(other_keys, fn key ->
        IO.puts("    #{key}: #{Map.get(data, key)}")
      end)
    end

    IO.puts("")
  end

  defp redact_email(email) when is_binary(email) do
    case String.split(email, "@") do
      [username, domain] ->
        redacted_username =
          if String.length(username) > 3 do
            String.slice(username, 0..2) <> "***"
          else
            "***"
          end

        "#{redacted_username}@#{domain}"

      _ ->
        "***"
    end
  end

  defp redact_email(_), do: "***"
end

# Run the test script
OuraClientTester.run()
