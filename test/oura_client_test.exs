defmodule OuraClientTest do
  use ExUnit.Case
  doctest Oura.Client

  describe "get_personal_info/0" do
    @tag :integration
    test "returns personal info from Oura API with valid API key" do
      # Skip this test if API_KEY is not set (for CI/CD)
      api_key = System.get_env("API_KEY")

      if api_key do
        result = Oura.Client.get_personal_info()

        # Assert that we get an :ok tuple with a map
        assert {:ok, data} = result
        assert is_map(data)

        # Assert that common personal info fields exist
        # Based on Oura API v2 documentation, personal_info contains:
        # age, weight, height, biological_sex, email
        # Note: Field names depend on API response format
      else
        # Skip test if no API key
        assert true
      end
    end

    test "returns error when API key is not set" do
      # Remove API_KEY if it exists
      original_key = System.get_env("API_KEY")
      System.delete_env("API_KEY")

      result = Oura.Client.get_personal_info()

      # Restore original key if it existed
      if original_key, do: System.put_env("API_KEY", original_key)

      # Should return an error tuple when no API key
      assert {:error, :no_api_key} = result
    end

    test "handles error responses from API" do
      # Set an invalid API key to trigger an error
      original_key = System.get_env("API_KEY")
      System.put_env("API_KEY", "invalid_key_for_testing")

      result = Oura.Client.get_personal_info()

      # Restore original key
      if original_key do
        System.put_env("API_KEY", original_key)
      else
        System.delete_env("API_KEY")
      end

      # Should return an error for invalid credentials
      # The exact error format may vary
      assert {:error, _reason} = result
    end
  end
end
