defmodule OuraRing.Client do
  @moduledoc """
  HTTP client for making requests to the Oura API.

  This module handles authentication, request formatting, pagination,
  and error handling for all API endpoints.
  """

  @base_url "https://api.ouraring.com"
  @api_version "v2"

  @type response :: {:ok, map() | list(map())} | {:error, term()}

  @doc """
  Makes a GET request to the Oura API.

  ## Parameters

  - `path` - The API endpoint path (e.g., "/usercollection/daily_sleep")
  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token
    - `:params` - Optional. Query parameters as a map or keyword list
    - `:paginate` - Optional. Whether to automatically fetch all pages (default: true)

  ## Returns

  - `{:ok, data}` - On success, returns the parsed response data
  - `{:error, reason}` - On failure, returns an error tuple

  ## Examples

      iex> OuraRing.Client.get("/usercollection/personal_info", access_token: "token")
      {:ok, %{"age" => 30, "email" => "user@example.com", ...}}

      iex> OuraRing.Client.get("/usercollection/daily_sleep",
      ...>   access_token: "token",
      ...>   params: %{start_date: "2025-01-01", end_date: "2025-01-07"}
      ...> )
      {:ok, [%{"id" => "...", "score" => 85, ...}, ...]}
  """
  @spec get(String.t(), keyword()) :: response()
  def get(path, opts \\ []) do
    access_token = Keyword.fetch!(opts, :access_token)
    params = Keyword.get(opts, :params, %{})
    paginate = Keyword.get(opts, :paginate, true)

    url = build_url(path)
    headers = build_headers(access_token)

    if paginate do
      get_paginated(url, headers, params)
    else
      get_single(url, headers, params)
    end
  end

  @doc """
  Makes a single GET request without pagination.
  """
  @spec get_single(String.t(), list(), map()) :: response()
  def get_single(url, headers, params) do
    case Req.get(url, headers: headers, params: params) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        parse_response(body)

      {:ok, %Req.Response{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %Req.Response{status: 404}} ->
        {:error, :not_found}

      {:ok, %Req.Response{status: 429}} ->
        {:error, :rate_limited}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Makes paginated GET requests, following `next_token` until all data is retrieved.
  """
  @spec get_paginated(String.t(), list(), map()) :: response()
  def get_paginated(url, headers, params, accumulated \\ []) do
    case get_single(url, headers, params) do
      {:ok, %{"data" => data, "next_token" => next_token}} when is_binary(next_token) ->
        # Continue pagination
        updated_params = Map.put(params, :next_token, next_token)
        get_paginated(url, headers, updated_params, accumulated ++ data)

      {:ok, %{"data" => data}} ->
        # Last page (no next_token)
        {:ok, accumulated ++ data}

      {:ok, data} when is_map(data) ->
        # Non-paginated response (e.g., personal_info)
        {:ok, data}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Formats dates and datetimes for API requests.

  ## Parameters

  - `start_date` - Date or DateTime
  - `end_date` - Date or DateTime (optional, defaults to today/now)

  ## Returns

  A map with `:start_date` and `:end_date` (or `:start_datetime` and `:end_datetime`)
  formatted as ISO 8601 strings.

  ## Examples

      iex> OuraRing.Client.format_date_range(~D[2025-01-01], ~D[2025-01-07])
      %{start_date: "2025-01-01", end_date: "2025-01-07"}

      iex> dt = DateTime.utc_now()
      iex> OuraRing.Client.format_date_range(dt, dt)
      %{start_datetime: "2025-01-01T12:00:00Z", end_datetime: "2025-01-01T12:00:00Z"}
  """
  @spec format_date_range(Date.t() | DateTime.t(), Date.t() | DateTime.t() | nil) :: map()
  def format_date_range(%Date{} = start_date, end_date \\ nil) do
    end_date = end_date || Date.utc_today()

    %{
      start_date: Date.to_iso8601(start_date),
      end_date: Date.to_iso8601(end_date)
    }
  end

  def format_date_range(%DateTime{} = start_datetime, end_datetime \\ nil) do
    end_datetime = end_datetime || DateTime.utc_now()

    %{
      start_datetime: DateTime.to_iso8601(start_datetime),
      end_datetime: DateTime.to_iso8601(end_datetime)
    }
  end

  @doc """
  Gets the default date range (yesterday to today).

  Used when no date range is specified for an API request.

  ## Examples

      iex> OuraRing.Client.default_date_range()
      %{start_date: "2025-01-17", end_date: "2025-01-18"}
  """
  @spec default_date_range() :: map()
  def default_date_range do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    %{
      start_date: Date.to_iso8601(yesterday),
      end_date: Date.to_iso8601(today)
    }
  end

  # Private functions

  defp build_url(path) do
    base = Application.get_env(:oura_ring, :base_url, @base_url)
    "#{base}/#{@api_version}#{path}"
  end

  defp build_headers(access_token) do
    [
      {"authorization", "Bearer #{access_token}"},
      {"content-type", "application/json"},
      {"accept", "application/json"}
    ]
  end

  defp parse_response(body) when is_map(body), do: {:ok, body}
  defp parse_response(body) when is_list(body), do: {:ok, body}
  defp parse_response(body), do: {:error, {:invalid_response, body}}
end
