defmodule OuraRing.DailyStress do
  @moduledoc """
  Access daily stress data from the Oura API.

  Daily stress provides insights into your stress levels and recovery, including:
  - Stress level (high, normal, low)
  - Recovery time in seconds
  - Daytime stress minutes
  - Stress score
  - And more

  Note: This feature is available for compatible Oura Ring generations.

  ## Example

      # Get stress data for the last 7 days
      {:ok, stress_data} = OuraRing.DailyStress.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7),
        end_date: Date.utc_today()
      )
  """

  alias OuraRing.Client

  @doc """
  Lists daily stress data for a date range.
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/daily_stress",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific daily stress document by ID.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/daily_stress/#{document_id}",
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
