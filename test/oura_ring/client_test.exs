defmodule OuraRing.ClientTest do
  use ExUnit.Case
  alias OuraRing.Client

  describe "format_date_range/2 with Date" do
    test "formats a date range correctly" do
      start_date = ~D[2025-01-01]
      end_date = ~D[2025-01-07]

      result = Client.format_date_range(start_date, end_date)

      assert result == %{
               start_date: "2025-01-01",
               end_date: "2025-01-07"
             }
    end

    test "uses today as end_date when not provided" do
      start_date = ~D[2025-01-01]
      today = Date.utc_today()

      result = Client.format_date_range(start_date)

      assert result == %{
               start_date: "2025-01-01",
               end_date: Date.to_iso8601(today)
             }
    end
  end

  describe "format_date_range/2 with DateTime" do
    test "formats a datetime range correctly" do
      start_datetime = ~U[2025-01-01 10:00:00Z]
      end_datetime = ~U[2025-01-01 20:00:00Z]

      result = Client.format_date_range(start_datetime, end_datetime)

      assert result == %{
               start_datetime: "2025-01-01T10:00:00Z",
               end_datetime: "2025-01-01T20:00:00Z"
             }
    end

    test "uses current time as end_datetime when not provided" do
      start_datetime = ~U[2025-01-01 10:00:00Z]

      result = Client.format_date_range(start_datetime)

      assert Map.has_key?(result, :start_datetime)
      assert Map.has_key?(result, :end_datetime)
      assert result.start_datetime == "2025-01-01T10:00:00Z"
    end
  end

  describe "default_date_range/0" do
    test "returns yesterday to today" do
      today = Date.utc_today()
      yesterday = Date.add(today, -1)

      result = Client.default_date_range()

      assert result == %{
               start_date: Date.to_iso8601(yesterday),
               end_date: Date.to_iso8601(today)
             }
    end
  end
end
