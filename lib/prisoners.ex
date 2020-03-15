defmodule Prisoners do
  @moduledoc """
  Documentation for `Prisoners`.
  """

  alias Prisoners.{Player, Tournament}

  @typedoc """
  This defines the allowed responses during player interactions
  """
  @type response :: :cooperate | :defect

  @typedoc """
  This defines the allowed responses to the `c:after_faceoff/
  """
  @type filter_result :: {:knockout, any} | {:unchanged | [Player.t]} | {:reproduced, [Player.t]}

  @doc """
  Entry point for a tournament: play a tournament with the given players using the given rules engine.

  Options:
    - `:rounds` : the number of rounds (i.e. iterations) in the tournament
  """
  @spec compete(players :: [{module, keyword}], rules_module :: module, opts :: keyword) :: any
  def compete(players, rules_module, opts \\ []) when is_list(players) do
    {rounds, opts} = Keyword.pop(opts, :rounds, 1)
#    tournament = Tournament.new(players, rules_module, opts)
    tournament = Enum.reduce(1..rounds, Tournament.new(players, rules_module, opts), fn _, tournament ->
      rules_module.play_round(tournament)
    end)
    %{tournament | finished_at: DateTime.utc_now()}
#    rules_module = Keyword.get(opts, :rules_module, Prisoners.RuleEngines.Simple)

#    permutate(tournament.players_refs, [], tournament)
  end

  def permutate([]), do: nil

  def permutate([_player1]), do: nil

#  def permutate([player1, player2]) do
#    IO.puts("Faceoff!  #{player1} vs #{player2}")
#  end

  # ABCD -> AB  (ACD, BCD)
  # ACD  -> AC  (AD, CD)
  # BCD  -> BC  (BD, CD)
  # AD
  # CD
  # BD
  # CD !!!


  def permutate([player1, player2 | rest]) do
    IO.puts("Faceoff!  #{player1} vs #{player2}")

    permutate([player1 | rest])
    permutate([player2 | rest])
#    spawn( fn -> permutate([player1 | rest], acc, tournament) end)
#    spawn( fn -> permutate([player2 | rest], acc, tournament) end)
  end
#
#  def faceoff(player1, player2, tournament) do
#    IO.puts("FACE OFF!!!")
##    player1_name = Map.get(tournament.players_map, player1)
#
#    player1_module = get_in(tournament, [Access.key(:players_map), Access.key(player1), Access.key(:module)])
#    player2_module = get_in(tournament, [Access.key(:players_map), Access.key(player2), Access.key(:module)])
#    IO.puts("Player1: #{player1_module}  Player2: #{player2_module}")
#    player1_response = player1_module.respond(player2, tournament)
#    player2_response = player2_module.respond(player1, tournament)
#    IO.puts("#{player1_response} #{player2_response}")
#  end

#  def shuffle(list), do: shuffle(list, 2)
#
#  def shuffle([], _), do: [[]]
#  def shuffle(_,  0), do: [[]]
#  def shuffle(list, i) do
#    for x <- list, y <- shuffle(list, i-1), do: [x|y]
#  end

  # From http://rosettacode.org/wiki/Combinations#Elixir
  # Usage:
  # Prisoners.comb(2, ~w|a b c d |)
  # [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]]
  def comb(0, _), do: [[]]
  def comb(_, []), do: []
  def comb(m, [h|t]) do
    (for l <- comb(m-1, t), do: [h|l]) ++ comb(m, t)
  end

#  def combinations(0, _), do: [[]]
#  def combinations(_, []), do: []
#  def combinations(i, [player|rest]) do
#    (for list <- combinations(i-1, rest), do: [player|list]) ++ combinations(i, rest)
#  end

  def combinations(0, _), do: [[]]
  def combinations(_, []), do: []
  def combinations(i, [player|rest]) do
    (for list <- combinations(i-1, rest), do: [player|list]) ++ combinations(i, rest)
  end
end
