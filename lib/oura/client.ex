defmodule Oura.Client do
  @moduledoc """
  Client for interacting with the Oura Ring API v2.

  Uses HTTPoison for HTTP requests and Jason for JSON parsing.
  """

  @base_url "https://api.ouraring.com/v2"

  @doc """
  Retrieves personal information from the Oura API.

  Returns `{:ok, data}` on success or `{:error, reason}` on failure.

  ## Examples

      iex> System.delete_env("API_KEY")
      iex> Oura.Client.get_personal_info()
      {:error, :no_api_key}

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
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_json(body)

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        {:error, {:http_error, status_code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {:request_failed, reason}}
    end
  end

  defp parse_json(json_string) do
    case Jason.decode(json_string) do
      {:ok, data} -> {:ok, data}
      {:error, reason} -> {:error, {:json_parse_error, reason}}
    end
  end
end
