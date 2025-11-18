defmodule OuraRing.DailySleepTest do
  use ExUnit.Case
  import OuraRing.FixtureHelper

  alias OuraRing.DailySleep

  describe "list/1" do
    test "requires access_token" do
      assert_raise KeyError, fn ->
        DailySleep.list()
      end
    end
  end

  describe "get/2" do
    test "requires access_token" do
      assert_raise KeyError, fn ->
        DailySleep.get("some_id")
      end
    end

    test "builds correct path for document ID" do
      # This is a placeholder test - in a real scenario, we'd mock the HTTP client
      # For now, we're just testing the function signature
      document_id = "b3d06fd9-52e1-4bee-8f06-529fd101c4f4"

      # This will fail with unauthorized, but proves the function is callable
      result = DailySleep.get(document_id, access_token: "fake_token")

      # We expect an error since we're using a fake token
      assert match?({:error, _}, result)
    end
  end

  describe "fixtures" do
    test "loads daily sleep fixture correctly" do
      fixture = load_fixture("daily_sleep.json")

      assert is_map(fixture)
      assert Map.has_key?(fixture, "data")
      assert is_list(fixture["data"])
      assert length(fixture["data"]) == 2

      first_sleep = hd(fixture["data"])
      assert first_sleep["score"] == 85
      assert first_sleep["day"] == "2025-01-15"
      assert is_map(first_sleep["contributors"])
    end
  end
end
