defmodule Prisoners.PlayerTest do
  use ExUnit.Case

  alias Prisoners.Player

  describe "new/2" do
    test "instantiate a single player" do
      assert %Player{} = Player.new(Prisoners.Strategies.AlwaysCooperate)
    end
  end
end
