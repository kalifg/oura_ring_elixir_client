defmodule OuraRingTest do
  use ExUnit.Case
  doctest OuraRing

  describe "version/0" do
    test "returns the library version" do
      version = OuraRing.version()
      assert is_binary(version)
      assert version =~ ~r/\d+\.\d+\.\d+/
    end
  end

  describe "base_url/0" do
    test "returns the default base URL" do
      assert OuraRing.base_url() == "https://api.ouraring.com"
    end

    test "returns configured base URL when set" do
      original_value = Application.get_env(:oura_ring, :base_url)

      try do
        Application.put_env(:oura_ring, :base_url, "https://custom.api.com")
        assert OuraRing.base_url() == "https://custom.api.com"
      after
        if original_value do
          Application.put_env(:oura_ring, :base_url, original_value)
        else
          Application.delete_env(:oura_ring, :base_url)
        end
      end
    end
  end

  describe "access_token/0" do
    test "returns nil when not configured" do
      original_value = Application.get_env(:oura_ring, :access_token)

      try do
        Application.delete_env(:oura_ring, :access_token)
        assert OuraRing.access_token() == nil
      after
        if original_value do
          Application.put_env(:oura_ring, :access_token, original_value)
        end
      end
    end

    test "returns configured access token when set" do
      original_value = Application.get_env(:oura_ring, :access_token)

      try do
        Application.put_env(:oura_ring, :access_token, "test_token_123")
        assert OuraRing.access_token() == "test_token_123"
      after
        if original_value do
          Application.put_env(:oura_ring, :access_token, original_value)
        else
          Application.delete_env(:oura_ring, :access_token)
        end
      end
    end
  end
end
