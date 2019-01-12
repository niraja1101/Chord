defmodule NewmoduleTest do
  use ExUnit.Case
  doctest Newmodule

  test "greets the world" do
    assert Newmodule.hello() == :world
  end
end
