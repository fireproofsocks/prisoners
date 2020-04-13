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
  The Rules Engine gets to decide how simple or complex the scoring calculations are!
  """
  @callback calculate_score(
              player1_pid :: pid,
              player2_pid :: pid,
              response1 :: atom,
              response2 :: atom,
              tournament :: Tournament.t()
            ) :: {number, number}

  @doc """
  From the given tournament, return a list of the active player PIDs. These are the players which are to participate
  in each round.

  A default implementation is provided.
  """
  @callback get_active_player_ids(Tournament.t()) :: [pid]

  @doc """
  This callback frames the tournament play.

  A default implementation is provided.
  """
  @callback play_tournament(tournament :: Tournament.t()) :: Tournament.t()

  @doc """
  This callback determines which players in the tournament must face-off with each other to constitute a round.

  A default implementation is provided.
  """
  @callback play_round(tournament :: Tournament.t()) :: Round.t()

  @doc """
  This callback handles the interaction between two players.

  A default implementation is provided.
  """
  @callback play_faceoff(pid1 :: pid, pid2 :: pid, tournament :: Tournament.t(), opts :: map) ::
              FaceOff.t()

  @doc """
  Return a list of valid responses that a player may give during a faceoff encounter.

  A default implementation is provided.
  """
  @callback valid_responses() :: [atom]

  @doc """
  Determines if the given player status should be considered "active".  Active players may be awarded points and
  continue playing into the next round.
  """
  @callback is_active_status?(atom) :: boolean

  defmacro __using__(_opts) do
    quote do
      alias Prisoners.{FaceOff, Player, Round, Rules, Tournament}

      use Prisoners.Utils

      @behaviour Rules

      @impl Rules
      def is_active_status?(status) do
        Enum.member?([:live], status)
      end

      @doc """
      Options:
      `n` : number of rounds
      """
      @impl Rules
      def play_tournament(tournament, opts \\ [])

      def play_tournament(tournament, opts) do
        n = ensure_pos_integer(Keyword.get(opts, :n, 1), :n)

        Enum.reduce(
          1..n,
          tournament,
          fn n, tournament ->
            round = Round.new()

            tournament
            |> tournament.rules_module.play_round()
            |> finish_round(round)
            |> accounting_for_round(tournament)
          end
        )
        |> Tournament.finish()
      end

      @spec finish_round([%FaceOff{}], Round.t()) :: Round.t()
      defp finish_round(faceoffs, %Round{} = round) do
        round
        |> Map.put(:response_count_by_type, Rules.summarize_faceoff_responses_by_type(faceoffs))
        |> Map.put(:faceoffs, faceoffs)
        |> Round.finish()
      end

      # Award points, log encounters to inboxes/outboxes
      @spec accounting_for_round(Round.t(), Tournament.t()) :: Tournament.t()
      defp accounting_for_round(%Round{faceoffs: faceoffs} = round, %Tournament{} = tournament) do
        faceoffs
        |> Enum.reduce(tournament, fn %{
                                        player1_id: pid1,
                                        player2_id: pid2,
                                        player1_response: resp1,
                                        player2_response: resp2,
                                        player1_points_received: p1_score,
                                        player2_points_received: p2_score
                                      },
                                      acc ->
          acc
          |> Tournament.increment_score(pid1, p1_score)
          |> Tournament.increment_score(pid2, p2_score)
          |> Tournament.remember_encounter(pid1, pid2, resp1, resp2)
        end)
        |> Tournament.put_round(round)
      end

      @doc """
      This implementation makes all faceoffs happen concurrently.
      Each faceoff will have a copy of the %Tournament{} data from the _start_ of the
      round, so the players do not have "live updates" from the other faceoffs.
      """
      @impl Rules
      def play_round(tournament) do
        caller = self()

        tournament
        |> get_active_player_ids()
        |> Rules.all_pairs()
        |> Enum.map(fn [pid1, pid2] ->
          spawn(fn ->
            send(caller, {self(), play_faceoff(pid1, pid2, tournament)})
          end)
        end)
        |> Enum.map(fn pid ->
          receive do
            {^pid, faceoff} -> faceoff
          end
        end)
      end

      @impl Rules
      def get_active_player_ids(tournament) do
        tournament.player_ids
        |> Enum.filter(fn pid ->
          tournament
          |> Tournament.player(pid, :status)
          |> tournament.rules_module.is_active_status?()
        end)
      end

      @impl Rules
      def play_faceoff(pid1, pid2, tournament, opts \\ [])

      def play_faceoff(pid1, pid2, tournament, _opts) do
        player1 = Tournament.player(tournament, pid1)
        player2 = Tournament.player(tournament, pid2)

        resp1 = player1.module.respond(player2, tournament)
        resp2 = player2.module.respond(player1, tournament)

        {p1_score, p2_score} = calculate_score(pid1, pid2, resp1, resp2, tournament)

        %FaceOff{
          player1_id: pid1,
          player2_id: pid2,
          player1_response: resp1,
          player2_response: resp2,
          player1_points_received: p1_score,
          player2_points_received: p2_score
        }
      end

      @impl Rules
      def valid_responses, do: [:defect, :cooperate]

      # A default implementation is provided, but a Rules Engine may implement their own
      defoverridable play_tournament: 1, play_round: 1, play_faceoff: 4, valid_responses: 0
    end
  end

  @doc """
  A reporting function which will summarize a list of faceoffs to tally the number of responses by response type.
  """
  @spec summarize_faceoff_responses_by_type(faceoffs :: [FaceOff.t()]) :: map
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
