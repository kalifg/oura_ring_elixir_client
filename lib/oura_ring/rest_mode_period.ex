defmodule OuraRing.RestModePeriod do
  @moduledoc """
  Access rest mode period data from the Oura API.

  Rest mode periods represent times when you've activated Rest Mode in your
  Oura app, typically during illness or recovery, including:
  - Start and end times
  - Episodes (periods within rest mode)
  - And more

  ## Example

      # Get rest mode periods for the last 30 days
      {:ok, rest_periods} = OuraRing.RestModePeriod.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -30),
        end_date: Date.utc_today()
      )
  """

  alias OuraRing.Client

  @doc """
  Lists rest mode periods for a date range.
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/rest_mode_period",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific rest mode period document by ID.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/rest_mode_period/#{document_id}",
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
