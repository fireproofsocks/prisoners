defmodule Prisoners.Rules do
  @moduledoc """
  Defines the callback "hooks" that a rule engine must implement in order to properly govern a `Tournament`.

  These callback functions are intended to be open-ended: it is up to a specific implementation to determine how
  simple or complex the rules are.
  """
  alias Prisoners.{FaceOff, Player, Tournament}

  #    @doc """
  #    This callback should be called immediately after a `FaceOff` between two players for each of the two players.
  #
  #    The rules engine implementation may use this opportunity to knock a player out of the tournament
  #    or to allow the `Player` to reproduce and return additional variants of itself.
  #    """
  #    @callback after_faceoff(player :: Player.t, faceoff :: FaceOff.t, tournament :: Tournament.t) :: [Player.t]

  #    @doc """
  #    This callback is called after a completed Tournament round for each of the players competing in the `Tournament`.
  #
  #    Depending on the rules engine implementation, this may cause a `Player` to be knocked out of the tournament
  #    or it may allow the `Player` to reproduce and return additional variants of itself.
  #
  #    This function has no effect when a tournament has only one round.
  #    """
  #    @callback after_round(player :: Player.t, faceoff :: FaceOff.t, tournament :: Tournament.t) :: [Player.t]

  @doc """
  Calculate the points to be awarded to the players after a `FaceOff`. The output of this function will be a tuple
  representing the scores to be granted to `{player1, player2}` (in that order).

  Scoring could be as simple as a [Truth Table](https://en.wikipedia.org/wiki/Truth_table) defining what points a
  `Player` receives after it gives one response and the opponent gives another, or it could be dynamic depending
  on multiple variables such as how many points the other `Player` has or the state of the `Tournament`.
  """
  @callback calculate_score(
              player1 :: Player.t(),
              player2 :: Player.t(),
              faceoff :: FaceOff.t(),
              tournament :: Tournament.t()
            ) :: {number, number}

  @doc """
  This callback determines which players in the tournament must face-off with each other to constitute a round.

  A default implementation is provided.
  """
  @callback play_round(tournament :: Tournament.t()) :: Tournament.t()

  @doc """
  Return a list of valid responses that a player may give during a faceoff encounter.

  A default implementation is provided.
  """
  @callback valid_responses() :: [atom]

  @doc """
  This callback handles the interaction between two players.

  A default implementation is provided.
  """
  @callback faceoff(
              player1 :: Player.t(),
              player2 :: Player.t(),
              tournament :: Tournament.t(),
              caller :: pid
            ) :: FaceOff.t()

  defmacro __using__(_opts) do
    quote do
      alias Prisoners.{FaceOff, Player, Round, Rules, Tournament}

      @behaviour Rules

      @impl Rules
      def play_round(tournament) do
        faceoffs = do_faceoffs(tournament)

        round = %Round{
          players_count_at_start: length(tournament.player_ids),
          faceoffs: faceoffs
        }

        # TODO:
        # weed out dead processes from player_ids
        round = %Round{
          round
          | players_count_at_finish: length(tournament.player_ids),
            response_count_by_type: Rules.summarize_faceoff_responses_by_type(round.faceoffs)
        }

        # call Player.after_round for each surviving player

        # Prepend this round to the tournament log...
        %Tournament{tournament | rounds: [round | tournament.rounds]}
      end

      # All faceoffs in a round happen concurrently, in parallel;
      # they only have a copy of the %Tournament{} data from the _start_ of the
      # round, so the players do not have "live updates" from the other faceoffs.
      defp do_faceoffs(tournament) do
        caller = self()

        tournament.player_ids
        |> Rules.all_pairs()
        |> Enum.map(fn [pid1, pid2] ->
          spawn(fn -> faceoff(pid1, pid2, tournament, caller) end)
        end)
        |> Enum.map(fn pid ->
          receive do
            {^pid, faceoff} -> faceoff
          end
        end)
      end

      @impl Rules
      def faceoff(pid1, pid2, tournament, caller) do
        player1 = Tournament.player(tournament, pid1)
        player2 = Tournament.player(tournament, pid2)
        # TODO: check response, kill process on bad response
        player1_response = player1.module.respond(player2, tournament)
        player2_response = player2.module.respond(player1, tournament)

        # Remember the encounter
        #        :ok = player1.module.remember_encounter(pid1, pid2, player1_response, player2_response)
        #        :ok = player2.module.remember_encounter(pid2, pid1, player2_response, player1_response)

        faceoff = %FaceOff{
          player1_id: pid1,
          player2_id: pid2,
          player1_response: player1_response,
          player2_response: player2_response
        }

        {p1_score, p2_score} = calculate_score(pid1, pid2, faceoff, tournament)

        # Remember the scores
        :ok = player1.module.increment_score(pid1, p1_score)
        :ok = player2.module.increment_score(pid2, p2_score)

        #        faceoff = %FaceOff{
        #          faceoff
        #          | player1_points_received: p1_score,
        #            player2_points_received: p2_score
        #        }

        # Send message back to caller with result
        send(
          caller,
          {self(),
           %FaceOff{
             faceoff
             | player1_points_received: p1_score,
               player2_points_received: p2_score
           }}
        )
      end

      @impl Rules
      def valid_responses, do: [:defect, :cooperate]

      # A default implementation is provided, but a Rules Engine may implement their own
      defoverridable play_round: 1, faceoff: 4, valid_responses: 0
    end
  end

  @doc """
  A reporting function which will summarize a list of faceoffs to tally the number of responses by response type.
  """
  @spec summarize_faceoff_responses_by_type(faceoffs :: [Faceoff.t()]) :: map
  def summarize_faceoff_responses_by_type(faceoffs) do
    Enum.reduce(
      faceoffs,
      %{},
      fn x, acc ->
        p1_response = Map.get(x, :player1_response)
        response1_cnt = Map.get(acc, p1_response, 0)
        acc = Map.put(acc, p1_response, response1_cnt + 1)

        p2_response = Map.get(x, :player2_response)
        response2_cnt = Map.get(acc, p2_response, 0)
        Map.put(acc, p2_response, response2_cnt + 1)
      end
    )
  end

  @doc """
  This function returns all possible pairs (2 members) from the given list (the order of the items in each pairing is
  not significant). It is provided as a convenience for implementing the`c:Prisoners.Rules.play_round/1` functionality
  where a rules engine regulates the facing off of players with each other: many rules engines will want to have each
  player encounter every other player.

  ## Examples
      iex> Prisoners.Rules.pairs(["a", "b", "c", "d"])
      [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]]

  """
  @spec all_pairs(list) :: list
  def all_pairs(list), do: combinations(2, list)

  # Adapted from http://rosettacode.org/wiki/Combinations#Elixir
  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(i, [player | rest]) do
    for(list <- combinations(i - 1, rest), do: [player | list]) ++ combinations(i, rest)
  end
end
