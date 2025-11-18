defmodule OuraRing.Tag do
  @moduledoc """
  Access tag data from the Oura API.

  Tags are user-created markers that help track activities, habits, or events,
  including:
  - Tag type (e.g., "coffee", "alcohol", "late_meal")
  - Timestamp
  - Custom notes
  - And more

  The Oura API provides two tag endpoints:
  - Enhanced Tags (recommended) - More detailed tag information
  - Tags (legacy) - Basic tag information

  ## Example

      # Get enhanced tags for the last 7 days
      {:ok, tags} = OuraRing.Tag.list_enhanced(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7),
        end_date: Date.utc_today()
      )

      # Get legacy tags
      {:ok, tags} = OuraRing.Tag.list(
        access_token: "YOUR_TOKEN",
        start_date: Date.add(Date.utc_today(), -7)
      )
  """

  alias OuraRing.Client

  @doc """
  Lists enhanced tag data for a date range.

  Enhanced tags provide more detailed information than legacy tags.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token
    - `:start_date` - Optional. Start date (Date or ISO 8601 string)
    - `:end_date` - Optional. End date (Date or ISO 8601 string)
  """
  @spec list_enhanced(keyword()) :: Client.response()
  def list_enhanced(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/enhanced_tag",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific enhanced tag document by ID.
  """
  @spec get_enhanced(String.t(), keyword()) :: Client.response()
  def get_enhanced(document_id, opts \\ []) do
    Client.get("/usercollection/enhanced_tag/#{document_id}",
      access_token: Keyword.fetch!(opts, :access_token),
      paginate: false
    )
  end

  @doc """
  Lists legacy tag data for a date range.

  Note: This endpoint is deprecated. Use `list_enhanced/1` instead.
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/tag",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  @doc """
  Gets a specific legacy tag document by ID.

  Note: This endpoint is deprecated. Use `get_enhanced/2` instead.
  """
  @spec get(String.t(), keyword()) :: Client.response()
  def get(document_id, opts \\ []) do
    Client.get("/usercollection/tag/#{document_id}",
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
