defmodule Prisoners.TournamentTest do
  use ExUnit.Case

  alias Prisoners.RuleEngines.Simple
  alias Prisoners.Strategies.AlwaysCooperate
  alias Prisoners.{Player, Tournament}

  describe "new/2" do
    test "instantiate a tournament" do
      assert %Tournament{} = Tournament.new([], Simple)
    end

    test "options passed as meta" do
      assert %Tournament{meta: [foo: :bar]} = Tournament.new([], Simple, foo: :bar)
    end

    test "raises on invalid rule module" do
      assert_raise RuntimeError, fn -> Tournament.new([], DoesNotExist) end
    end

    test "raises on invalid player module" do
      assert_raise RuntimeError, fn -> Tournament.new([{DoesNotExist, []}], Simple) end
    end

    test "tournament registers all players passed" do
      assert %Tournament{player_ids: [_]} = Tournament.new([{AlwaysCooperate, []}], Simple)
    end

    test "instantiates multiple instances of players given the n option" do
      n = 2
      %Tournament{player_ids: player_ids} = Tournament.new([{AlwaysCooperate, n: n}], Simple)
      assert n == length(player_ids)
    end

    test "raises error when player option n is not an integer" do
      assert_raise RuntimeError, fn -> Tournament.new([{AlwaysCooperate, n: "barf"}], Simple) end
    end

    test "raises error when player option n is not greater than zero" do
      assert_raise RuntimeError, fn -> Tournament.new([{AlwaysCooperate, n: -1}], Simple) end
    end
  end

  describe "pairs/1" do
    test "all combinations found" do
      assert [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]] ==
               Tournament.pairs(["a", "b", "c", "d"])
    end
  end

  describe "player/2" do
    test "gets the player by its pid" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)
      pid = hd(tournament.player_ids)
      result = Tournament.player(tournament, pid)
      assert %Player{} = result
      assert result.module == AlwaysCooperate
    end

    test "nil on bogus pid" do
      tournament = Tournament.new([], Simple)
      assert nil == Tournament.player(tournament, "bunk")
    end
  end
end
