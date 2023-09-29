defmodule WDGTest do
  use ExUnit.Case
  doctest WDG

  test "greets the world" do
    assert WDG.hello() == :world
  end
end
