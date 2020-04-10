defmodule Prisoners.TournamentTest do
  use ExUnit.Case

  alias Prisoners.RuleEngines.Simple
  alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}
  alias Prisoners.{Player, Round, Tournament}

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

  describe "finish/1" do
    test "adds finished_at" do
      t = Tournament.new([], Simple, foo: :bar)
      %Tournament{finished_at: finished_at} = Tournament.finish(t)
      assert finished_at != nil
    end
  end

  describe "player/2" do
    test "gets the player by its pid" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)
      pid = hd(tournament.player_ids)
      assert %Player{module: AlwaysCooperate} = Tournament.player(tournament, pid)
    end

    test "nil on bogus pid" do
      tournament = Tournament.new([], Simple)
      assert nil == Tournament.player(tournament, "bunk")
    end
  end

  describe "player/3" do
    test "gets the player attribute requested" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)
      pid = hd(tournament.player_ids)
      assert AlwaysCooperate = Tournament.player(tournament, pid, :module)
    end
  end

  describe "increment_score/3" do
    test "updates properly" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)
      pid = hd(tournament.player_ids)

      assert %Tournament{players_map: %{^pid => %{score: 6}}} =
               tournament = Tournament.increment_score(tournament, pid, 6)

      assert %Tournament{players_map: %{^pid => %{score: 12}}} =
               Tournament.increment_score(tournament, pid, 6)
    end
  end

  describe "update_status/3" do
    test "updates properly" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)
      pid = hd(tournament.player_ids)

      assert %Tournament{players_map: %{^pid => %{status: :winner}}} =
               Tournament.update_status(tournament, pid, :winner)
    end
  end

  describe "put_round/2" do
    test "updates properly" do
      tournament = Tournament.new([{AlwaysCooperate, []}], Simple)

      assert %Tournament{rounds: [%Round{players_count_at_start: 7}]} =
               Tournament.put_round(tournament, %Round{players_count_at_start: 7})
    end
  end

  describe "remember_encounter/5" do
    test "updates properly, puts most recent response at the front of the list" do
      tournament = Tournament.new([{AlwaysCooperate, []}, {AlwaysDefect, []}], Simple)
      [pid1, pid2] = tournament.player_ids

      tournament = Tournament.remember_encounter(tournament, pid1, pid2, :cooperate, :defect)

      assert %Tournament{
               players_map: %{
                 ^pid1 => %Player{inbox: %{^pid2 => [:defect]}, outbox: %{^pid2 => [:cooperate]}},
                 ^pid2 => %Prisoners.Player{
                   inbox: %{^pid1 => [:cooperate]},
                   outbox: %{^pid1 => [:defect]}
                 }
               }
             } = tournament

      assert %Tournament{
               players_map: %{
                 ^pid1 => %Player{
                   inbox: %{^pid2 => [:defect1, :defect]},
                   outbox: %{^pid2 => [:cooperate1, :cooperate]}
                 },
                 ^pid2 => %Prisoners.Player{
                   inbox: %{^pid1 => [:cooperate1, :cooperate]},
                   outbox: %{^pid1 => [:defect1, :defect]}
                 }
               }
             } = Tournament.remember_encounter(tournament, pid1, pid2, :cooperate1, :defect1)
    end
  end
end
