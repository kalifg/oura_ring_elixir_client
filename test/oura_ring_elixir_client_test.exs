defmodule OuraRingElixirClientTest do
  use ExUnit.Case
  doctest OuraRingElixirClient

  test "greets the world" do
    assert OuraRingElixirClient.hello() == :world
  end
end
