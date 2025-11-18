defmodule OuraRing.RingConfiguration do
  @moduledoc """
  Access ring configuration data from the Oura API.

  Ring configuration provides details about your Oura Ring hardware, including:
  - Ring model and generation
  - Ring size
  - Hardware version
  - Firmware version
  - Color
  - And more

  ## Example

      # Get ring configuration data
      {:ok, config} = OuraRing.RingConfiguration.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -30),
        end_date: Date.utc_today()
      )
  """

  alias OuraRing.Client

  @doc """
  Lists ring configuration data for a date range.
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/ring_configuration",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific ring configuration document by ID.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/ring_configuration/#{document_id}",
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
