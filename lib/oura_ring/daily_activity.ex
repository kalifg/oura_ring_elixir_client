defmodule OuraRing.DailyActivity do
  @moduledoc """
  Access daily activity data from the Oura API.

  Daily activity provides comprehensive analysis of your movement and activity, including:
  - Activity scores and contributors
  - Steps and equivalent walking distance
  - Active calories and total calories
  - MET (Metabolic Equivalent) minutes at different levels
  - Inactivity and rest periods
  - Training frequency and volume
  - And more

  ## Example

      # Get activity data for the last 7 days
      {:ok, activity_data} = OuraRing.DailyActivity.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7),
        end_date: Date.utc_today()
      )

      # Get a specific activity document by ID
      {:ok, activity} = OuraRing.DailyActivity.get(
        "document_id_here",
        access_token: "YOUR_TOKEN"
      )
  """

  alias OuraRing.Client

  @doc """
  Lists daily activity data for a date range.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token
    - `:start_date` - Optional. Start date (Date or ISO 8601 string). Defaults to yesterday.
    - `:end_date` - Optional. End date (Date or ISO 8601 string). Defaults to today.

  ## Returns

  - `{:ok, list}` - List of daily activity documents
  - `{:error, reason}` - Error tuple

  ## Examples

      {:ok, activity_data} = OuraRing.DailyActivity.list(
        access_token: token,
        start_date: ~D[2025-01-01],
        end_date: ~D[2025-01-07]
      )
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/daily_activity",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific daily activity document by ID.

  ## Parameters

  - `document_id` - The ID of the activity document to retrieve
  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token

  ## Returns

  - `{:ok, map}` - The activity document
  - `{:error, reason}` - Error tuple

  ## Examples

      {:ok, activity} = OuraRing.DailyActivity.get(
        "b3d06fd9-52e1-4bee-8f06-529fd101c4f4",
        access_token: token
      )
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/daily_activity/#{document_id}",
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
