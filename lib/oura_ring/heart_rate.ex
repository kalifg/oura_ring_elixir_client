defmodule OuraRing.HeartRate do
  @moduledoc """
  Access heart rate data from the Oura API.

  Heart rate data provides 5-minute interval samples throughout the day, including:
  - BPM (beats per minute)
  - Source (e.g., sleep, awake, workout)
  - Timestamp

  ## Example

      # Get heart rate data for the last 24 hours
      start_time = DateTime.add(DateTime.utc_now(), -86400, :second)
      end_time = DateTime.utc_now()

      {:ok, heart_rate_data} = OuraRing.HeartRate.list(
        access_token: "YOUR_TOKEN",
        start_datetime: start_time,
        end_datetime: end_time
      )
  """

  alias OuraRing.Client

  @doc """
  Lists heart rate data for a datetime range.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token
    - `:start_datetime` - Optional. Start datetime (DateTime or ISO 8601 string)
    - `:end_datetime` - Optional. End datetime (DateTime or ISO 8601 string)

  ## Returns

  - `{:ok, list}` - List of heart rate documents
  - `{:error, reason}` - Error tuple

  ## Examples

      {:ok, heart_rate} = OuraRing.HeartRate.list(
        access_token: token,
        start_datetime: ~U[2025-01-01 00:00:00Z],
        end_datetime: ~U[2025-01-01 23:59:59Z]
      )
  """
  @spec list(keyword()) :: Client.response()
  def list(opts \\ []) do
    params = build_params(opts)

    Client.get("/usercollection/heartrate",
      access_token: Keyword.fetch!(opts, :access_token),
      params: params,
      paginate: true
    )
  end

  # Private functions

  defp build_params(opts) do
    start_datetime = Keyword.get(opts, :start_datetime)
    end_datetime = Keyword.get(opts, :end_datetime)

    cond do
      start_datetime && end_datetime ->
        Client.format_date_range(parse_datetime(start_datetime), parse_datetime(end_datetime))

      start_datetime ->
        Client.format_date_range(parse_datetime(start_datetime), DateTime.utc_now())

      true ->
        # Default to last 24 hours for datetime-based endpoints
        now = DateTime.utc_now()
        yesterday = DateTime.add(now, -86400, :second)
        Client.format_date_range(yesterday, now)
    end
  end

  defp parse_datetime(%DateTime{} = dt), do: dt

  defp parse_datetime(dt_string) when is_binary(dt_string) do
    case DateTime.from_iso8601(dt_string) do
      {:ok, dt, _offset} -> dt
      {:error, _} -> raise ArgumentError, "Invalid datetime string: #{dt_string}"
    end
  end
end
