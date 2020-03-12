defmodule Prisoners.Rules do
    @moduledoc """
    Defines the callback "hooks" that a rule engine must define in order to properly govern a `Tournament`.

    These callback functions are intended to be open-ended: it is up to a specific implementation to determine how
    simple or complex the rules are.
    """
    alias Prisoners.{FaceOff, Player, Tournament}

    @doc """
    This callback should be called immediately after a `FaceOff` between two players for each of the two players.

    The rules engine implementation may use this opportunity to knock a player out of the tournament
    or to allow the `Player` to reproduce and return additional variants of itself.
    """
    @callback after_faceoff(player :: Player.t, faceoff :: FaceOff.t, tournament :: Tournament.t) :: [Player.t]

    @doc """
    This callback is called after a completed Tournament round for each of the players competing in the `Tournament`.

    Depending on the rules engine implementation, this may cause a `Player` to be knocked out of the tournament
    or it may allow the `Player` to reproduce and return additional variants of itself.

    This function has no effect when a tournament has only one round.
    """
    @callback after_round(player :: Player.t, faceoff :: FaceOff.t, tournament :: Tournament.t) :: [Player.t]

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

    A functioning implementation is provided.
    """
    @callback play_round(tournament :: Tournament.t) :: Tournament.t

    defmacro __using__(_opts) do
        quote do
            alias Prisoners.Rules

            @behaviour Rules

            @impl Rules
            def play_round(tournament) do
                IO.puts("Playing round! #{__MODULE__}")
                # Note: __MODULE__ will not be the Prisoners.Rules module; it will be the module that _used_ it.
                Rules.permutate_players(tournament.players_refs, [], tournament, __MODULE__)
                # tournament.rules_engine.after_round() # TODO
            end

            # A default implementation is provided, but a Rules Engine may implement their own
            defoverridable play_round: 1
        end
    end

    @doc """
    This function is provided as a convenience for implementing the `c:play_round/1` functionality: it will work
    through all player combinations for each round and ensure that each player has one face-off with each of the others.

    For example, a round with players `ABCD` will generate the following face-offs: `AB`, `AC`, `AD`, `BC`, `BD`, `CD`.

    This implementation will call the expected callbacks during
    """
    @spec permutate_players(players_list :: list, acc :: list, tournament :: Tournament.t, rules_module :: module) :: list
    def permutate_players([], _acc, tournament, _rules_module), do: tournament

    def permutate_players([_player1], _acc, tournament, _rules_module), do: tournament

    def permutate_players([player1, player2 | rest], acc, tournament, rules_module) do

        result = faceoff(player1, player2, tournament, rules_module)

#        rules_module.after_round(player1, faceoff, tournament)
#        case result do
#
#        end
#        tournament = permutate_players([player1] ++ [rest], acc, tournament, rules_module)
        tournament = permutate_players([player1 | rest], acc, tournament, rules_module)
        permutate_players([player2 | rest], acc, tournament, rules_module)
    end

    @doc """
    This is another convenience function that deals with the nitty-gritty of two players facing off and recording
    their scores and calling
    """
    def faceoff(player1, player2, tournament, rules_module) do
        IO.puts("FACE OFF!!!")
        #    player1_name = Map.get(tournament.players_map, player1)

        player1_module = Tournament.player(tournament, player1)
        player2_module = Tournament.player(tournament, player2)
        IO.puts("Player1: #{player1_module}  Player2: #{player2_module}")
        player1_response = player1_module.respond(player2, tournament)
        player2_response = player2_module.respond(player1, tournament)
        IO.puts("#{player1_response} #{player2_response}")
    end
end