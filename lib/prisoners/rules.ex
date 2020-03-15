defmodule Prisoners.Rules do
    @moduledoc """
    Defines the callback "hooks" that a rule engine must define in order to properly govern a `Tournament`.

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
    @callback calculate_score(player1 :: Player.t, player2 :: Player.t, faceoff :: FaceOff.t, tournament :: Tournament.t) :: {number, number}

    @doc """
    This callback determines which players in the tournament must face-off with each other to constitute a round.

    A default implementation is provided.
    """
    @callback play_round(tournament :: Tournament.t) :: Tournament.t


    @doc """
    This callback handles the interaction between two players.

    A default implementation is provided.
    """
    @callback faceoff(player1 :: Player.t, player2 :: Player.t, tournament :: Tournament.t, caller::pid) :: FaceOff.t

    defmacro __using__(_opts) do
        quote do
            alias Prisoners.Rules

            @behaviour Rules

            @impl Rules
            def play_round(tournament) do
                IO.puts("Playing round! #{__MODULE__}")
                caller = self()
                # 1:1 map Collect FaceOffs: [pairs] --> [FaceOffs]
                # Note: __MODULE__ will not be the Prisoners.Rules module; it will be the module that _used_ it.
                faceoffs = tournament.player_ids
                |> Rules.pairs()
                # &(spawn(fn -> process(&1, caller) end))
                # |> Enum.map(&(spawn(fn -> process(&1, caller) end)))
                  # 1:1 map Collect FaceOff PIDs: [pairs] --> [pids]
                |> Enum.map(fn [pid1, pid2] -> spawn(fn -> faceoff(pid1, pid2, tournament, caller) end) end)
#                |> Enum.map(&(spawn(fn -> Rules.faceoff(&1, caller) end)))
#                Enum.map(pairs, fn [pid1, pid2] ->
#                    Rules.faceoff(pid1, pid2, tournament, __MODULE__)
#                end)
                  # Map the returned pids
                |> Enum.map(fn pid ->
                  # Receive the response from this pid
                    receive do
                        {^pid, faceoff} -> faceoff
                    end
                end)
                |> Enum.reduce(tournament.faceoffs, fn x, acc ->
                    [x | acc]
                end)

                Map.put(tournament, :faceoffs, faceoffs)
                # 1:1 map? Collect roster for next round ????  [pid] -> [pid]
                # tournament.rules_engine.after_round() # TODO
            end

            @impl Rules
            def faceoff(pid1, pid2, tournament, caller) do

                player1 = Tournament.player(tournament, pid1)
                player2 = Tournament.player(tournament, pid2)
                # TODO: check response, kill process on bad response
                player1_response = player1.module.respond(player2, tournament)
                player2_response = player2.module.respond(player1, tournament)

                faceoff = %FaceOff{
                    player1_id: pid1,
                    player2_id: pid2,
                    player1_response: player1_response,
                    player2_response: player2_response,
                }

                {p1_score, p2_score} = calculate_score(pid1, pid2, faceoff, tournament)

                faceoff = %{faceoff | player1_points_received: p1_score, player2_points_received: p2_score}

                # Send message back to caller with result
                send(caller, {self(), faceoff})
            end

            # A default implementation is provided, but a Rules Engine may implement their own
            defoverridable play_round: 1, faceoff: 4
        end
    end

    @doc """
    This function returns all possible pairs from a list. It is provided as a convenience for implementing the
    `c:play_round/1` functionality where a rules engine regulates the facing off of players with each other.

    ## Examples
        iex> Rules.pairs(["a", "b", "c", "d"])
        [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]]

    """
    @spec pairs(list) :: list
    def pairs(list), do: combinations(2, list)

    # Adapted from http://rosettacode.org/wiki/Combinations#Elixir
    defp combinations(0, _), do: [[]]
    defp combinations(_, []), do: []
    defp combinations(i, [player|rest]) do
        (for list <- combinations(i-1, rest), do: [player|list]) ++ combinations(i, rest)
    end

end