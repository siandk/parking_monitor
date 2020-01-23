defmodule ParkMonTest do
  use ExUnit.Case
  doctest ParkMon

  test "greets the world" do
    assert ParkMon.hello() == :world
  end
end
