defmodule OuraRing.SleepTime do
  @moduledoc """
  Access ideal bedtime recommendations from the Oura API.

  Sleep time provides recommendations for optimal bedtime based on your
  sleep patterns and circadian rhythm, including:
  - Recommended bedtime window
  - Sleep need (hours)
  - Sleep regularity score
  - And more

  ## Example

      # Get sleep time recommendations for the last 7 days
      {:ok, sleep_time} = OuraRing.SleepTime.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7),
        end_date: Date.utc_today()
      )
  """

  alias OuraRing.Client

  @doc """
  Lists sleep time recommendations for a date range.
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/sleep_time",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific sleep time document by ID.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/sleep_time/#{document_id}",
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
