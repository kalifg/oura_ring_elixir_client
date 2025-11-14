defmodule Oura.Client do
  @moduledoc """
  Client for interacting with the Oura Ring API v2.

  Note: Currently using built-in :httpc and manual JSON parsing.
  In production, consider using {:httpoison, "~> 2.0"} and {:jason, "~> 1.4"}
  """

  @base_url "https://api.ouraring.com/v2"

  @doc """
  Retrieves personal information from the Oura API.

  Returns `{:ok, data}` on success or `{:error, reason}` on failure.
  """
  def get_personal_info do
    case System.get_env("API_KEY") do
      nil ->
        {:error, :no_api_key}

      api_key ->
        url = "#{@base_url}/usercollection/personal_info"
        make_request(url, api_key)
    end
  end

  # Private functions

  defp make_request(url, api_key) do
    # Start :inets and :ssl applications
    :inets.start()
    :ssl.start()

    headers = [
      {'Authorization', 'Bearer #{api_key}'}
    ]

    # Make HTTP request using :httpc
    case :httpc.request(:get, {String.to_charlist(url), headers}, [], []) do
      {:ok, {{_http_version, 200, _status_msg}, _headers, body}} ->
        # Parse JSON response
        case parse_json(to_string(body)) do
          {:ok, data} -> {:ok, data}
          {:error, reason} -> {:error, {:json_parse_error, reason}}
        end

      {:ok, {{_http_version, status_code, _status_msg}, _headers, body}} ->
        {:error, {:http_error, status_code, to_string(body)}}

      {:error, reason} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp parse_json(json_string) do
    # Simple JSON parser using :json module (available in Erlang/OTP 27+)
    # For older versions, we'll use a basic regex-based approach
    try do
      # Try using Erlang's :json module if available
      case :erlang.function_exported(:json, :decode, 1) do
        true ->
          {:ok, :json.decode(json_string)}

        false ->
          # Fallback: basic JSON parsing for simple objects
          parse_json_basic(json_string)
      end
    rescue
      e -> {:error, {:parse_error, e}}
    end
  end

  defp parse_json_basic(json_string) do
    # Very basic JSON parser for simple objects
    # This is a simplified implementation - in production use Jason or similar
    try do
      # Remove outer braces and whitespace
      cleaned =
        json_string
        |> String.trim()
        |> String.trim_leading("{")
        |> String.trim_trailing("}")

      # Split by commas (naive approach)
      pairs =
        cleaned
        |> String.split(~r/,(?=\s*"[^"]+"\s*:)/)
        |> Enum.map(&parse_key_value/1)
        |> Enum.into(%{})

      {:ok, pairs}
    rescue
      e -> {:error, {:basic_parse_error, e}}
    end
  end

  defp parse_key_value(pair) do
    case String.split(pair, ":", parts: 2) do
      [key, value] ->
        clean_key = String.trim(key) |> String.trim("\"")
        clean_value = parse_value(String.trim(value))
        {clean_key, clean_value}

      _ ->
        {"unknown", nil}
    end
  end

  defp parse_value(value) do
    value = String.trim(value)

    cond do
      # String value
      String.starts_with?(value, "\"") ->
        String.trim(value, "\"")

      # Number
      String.match?(value, ~r/^-?\d+\.?\d*$/) ->
        case String.contains?(value, ".") do
          true -> String.to_float(value)
          false -> String.to_integer(value)
        end

      # Boolean
      value == "true" ->
        true

      value == "false" ->
        false

      # Null
      value == "null" ->
        nil

      # Default
      true ->
        value
    end
  end
end
