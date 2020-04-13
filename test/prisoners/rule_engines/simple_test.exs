defmodule Prisoners.RuleEngines.SimpleTest do
  use ExUnit.Case
  alias Prisoners.{FaceOff, Tournament}
  alias Prisoners.RuleEngines.Simple
  alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}

  describe "play_faceoff/4" do
    test "ensure proper scoring and responses" do
      tournament = Tournament.new([{AlwaysCooperate, []}, {AlwaysDefect, []}], Simple)
      [pid1, pid2] = tournament.player_ids

      assert %FaceOff{
               player1_points_received: -1,
               player1_response: :cooperate,
               player2_points_received: 2,
               player2_response: :defect
             } = Simple.play_faceoff(pid1, pid2, tournament, nil)
    end
  end

  describe "play_round/1" do
    test "round returned with all faceoffs" do
      tournament = Tournament.new([{AlwaysCooperate, []}, {AlwaysDefect, []}], Simple)

      assert [
               %FaceOff{
                 player1_points_received: -1,
                 player1_response: :cooperate,
                 player2_points_received: 2,
                 player2_response: :defect
               }
             ] = Simple.play_round(tournament)
    end
  end

  describe "play_tournament/1" do
    test "round scored and accounted for" do
      tournament = Tournament.new([{AlwaysCooperate, []}, {AlwaysDefect, []}], Simple)
      [pid1, pid2] = tournament.player_ids

      assert %Tournament{
               rounds: [_],
               players_map: %{
                 ^pid1 => %{
                   score: -1,
                   inbox: %{^pid2 => [:defect]},
                   outbox: %{^pid2 => [:cooperate]}
                 },
                 ^pid2 => %{
                   score: 2,
                   inbox: %{^pid1 => [:cooperate]},
                   outbox: %{^pid1 => [:defect]}
                 }
               }
             } = Simple.play_tournament(tournament)
    end
  end
end
