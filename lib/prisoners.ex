defmodule Prisoners do
  @moduledoc """
  Documentation for `Prisoners`.
  """

  alias Prisoners.{Player, Tournament}

  @typedoc """
  This defines the allowed responses during player interactions
  """
  @type response :: :cooperate | :defect

  @doc """
  Entry point for a tournament
  """
  def compete(players, opts \\ []) when is_list(players) do
#    rules_module = Keyword.get(opts, :rules_module, Prisoners.RuleEngines.Simple)
    tournament = Tournament.new(players, opts)
    permutate(tournament.players_refs, [], tournament)
  end

  def permutate([], acc, tournament), do: acc

  def permutate([_player1], acc, tournament), do: acc

  def permutate([player1, player2 | rest], acc, tournament) do

    result = faceoff(player1, player2, tournament)

    spawn( fn -> permutate([player1 | rest], acc, tournament) end)
    spawn( fn -> permutate([player2 | rest], acc, tournament) end)
  end

  def faceoff(player1, player2, tournament) do
    IO.puts("FACE OFF!!!")
#    player1_name = Map.get(tournament.players_map, player1)

    player1_module = get_in(tournament, [Access.key(:players_map), Access.key(player1), Access.key(:module)])
    player2_module = get_in(tournament, [Access.key(:players_map), Access.key(player2), Access.key(:module)])
    IO.puts("Player1: #{player1_module}  Player2: #{player2_module}")
    player1_response = player1_module.respond(player2, tournament)
    player2_response = player2_module.respond(player1, tournament)
    IO.puts("#{player1_response} #{player2_response}")
  end
end
