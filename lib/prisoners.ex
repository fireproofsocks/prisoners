defmodule Prisoners do
  @moduledoc """
  Documentation for `Prisoners`.
  """

  @doc """
  Entry point for a tournament
  """
  def compete(players, _opts) when is_list(players) do
  end

  def permutate([], acc), do: acc

  def permutate([_player1], acc), do: acc

  def permutate([player1, player2 | rest], acc) do
    IO.puts("FACE OFF!!! Player1 #{player1} vs. Player2 #{player2}")
    permutate([player1 | rest], acc)
    permutate([player2 | rest], acc)
  end
end
