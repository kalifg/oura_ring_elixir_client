defmodule OuraRing.PersonalInfo do
  @moduledoc """
  Access personal information from the Oura API.

  Personal information includes user demographic data such as:
  - Age
  - Weight
  - Height
  - Biological sex
  - Email address

  Note: Unlike other endpoints, personal info is not date-based and does not
  support pagination or date filtering.

  ## Example

      # Get your personal information
      {:ok, info} = OuraRing.PersonalInfo.get(access_token: "YOUR_TOKEN")

      # Returns a map like:
      # %{
      #   "age" => 30,
      #   "weight" => 70.5,
      #   "height" => 1.75,
      #   "biological_sex" => "male",
      #   "email" => "user@example.com"
      # }
  """

  alias OuraRing.Client

  @doc """
  Gets the user's personal information.

  ## Parameters

  - `opts` - Keyword list of options:
    - `:access_token` - Required. Your Oura Personal Access Token

  ## Returns

  - `{:ok, map}` - A map containing personal information
  - `{:error, reason}` - Error tuple

  ## Examples

      {:ok, info} = OuraRing.PersonalInfo.get(access_token: token)
      IO.inspect(info["age"])
      IO.inspect(info["email"])
  """
  @spec get(keyword()) :: Client.response()
  def get(opts \\ []) do
    Client.get("/usercollection/personal_info",
      access_token: Keyword.fetch!(opts, :access_token),
      paginate: false
    )
  end
end
