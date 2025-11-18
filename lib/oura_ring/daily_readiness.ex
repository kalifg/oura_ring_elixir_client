defmodule OuraRing.DailyReadiness do
  @moduledoc """
  Access daily readiness data from the Oura API.

  Daily readiness provides insights into your body's recovery and readiness
  to perform, including:
  - Readiness score and contributors
  - Temperature deviation
  - HRV balance
  - Recovery index
  - Sleep balance
  - Previous day's activity
  - And more

  ## Example

      # Get readiness data for the last 7 days
      {:ok, readiness_data} = OuraRing.DailyReadiness.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7),
        end_date: Date.utc_today()
      )
  """

  alias OuraRing.Client

  @doc """
  Lists daily readiness data for a date range.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token
    - `:start_date` - Optional. Start date (Date or ISO 8601 string). Defaults to yesterday.
    - `:end_date` - Optional. End date (Date or ISO 8601 string). Defaults to today.

  ## Returns

  - `{:ok, list}` - List of daily readiness documents
  - `{:error, reason}` - Error tuple
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/daily_readiness",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific daily readiness document by ID.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/daily_readiness/#{document_id}",
      access_token: Keyword.fetch!(opts, :access_token),
      paginate: false
    )
  end

  # Private functions

  defp build_params(opts) do
    start_date = Keyword.get(opts, :start_date)
    end_date = Keyword.get(opts, :end_date)

    cond do
      start_date && end_date ->
        Client.format_date_range(parse_date(start_date), parse_date(end_date))

      start_date ->
        Client.format_date_range(parse_date(start_date), Date.utc_today())

      true ->
        Client.default_date_range()
    end
  end

  defp parse_date(%Date{} = date), do: date
  defp parse_date(date_string) when is_binary(date_string), do: Date.from_iso8601!(date_string)
end
