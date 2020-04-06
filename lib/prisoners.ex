defmodule Prisoners do
  @moduledoc """
  Documentation for `Prisoners`.
  """

  alias Prisoners.{Player, Tournament}

  require Logger

  @typedoc """
  This defines the allowed responses during player interactions
  """
  @type response :: :cooperate | :defect

  @typedoc """
  This defines the allowed responses to the `c:after_faceoff/
  """
  @type filter_result ::
          {:knockout, any} | {:unchanged | [Player.t()]} | {:reproduced, [Player.t()]}

  @doc """
  Entry point for a tournament: play a tournament with the given players using the given rules engine.

  Options:
    - `:rounds` (integer) : the number of rounds (i.e. iterations) in the tournament. Default: `1`
    - `:n` (integer) : the number of concurrent tournaments to run. Default `1`

  """
  @spec compete(players :: [{module, keyword}], rules_module :: module, opts :: keyword) :: [
          Tournament.t()
        ]
  def compete(players, rules_module, opts \\ [])

  def compete(players, rules_module, opts) when is_list(players) and is_atom(rules_module) do
    {rounds, opts} = ensure_pos_integer(Keyword.pop(opts, :rounds, 1), :rounds)
    {n, opts} = ensure_pos_integer(Keyword.pop(opts, :n, 1), :n)
    Logger.info("Starting #{n} concurrent tournaments, each with #{rounds} rounds")
    caller = self()
    tournament = Tournament.new(players, rules_module, opts)

    1..n
    |> Enum.map(fn _ ->
      spawn(fn ->
        tournament
        |> Map.put(:id, self())
        |> Map.put(:rounds_count, rounds)
        |> Map.put(:concurrent_count, n)
        |> Map.put(:started_at, DateTime.utc_now())
        |> do_tournament(rules_module, rounds, caller)
      end)
    end)
    |> Enum.map(fn pid ->
      receive do
        {^pid, tournament} ->
          tournament
          |> Map.put(:finished_at, DateTime.utc_now())
      end
    end)
  end

  # play a tournament (all rounds) in process
  defp do_tournament(tournament, rules_module, rounds, caller) do
    tournament =
      Enum.reduce(1..rounds, tournament, fn _, tournament ->
        rules_module.play_round(tournament)
      end)

    %Tournament{tournament | finished_at: DateTime.utc_now()}
    # Send message back to caller with result
    send(caller, {self(), tournament})
  end

  @spec ensure_pos_integer(tuple, atom) :: tuple
  defp ensure_pos_integer({n, opts}, _) when is_integer(n) and n > 0, do: {n, opts}

  @spec ensure_pos_integer(tuple, atom) :: tuple
  defp ensure_pos_integer(_, name) do
    raise "Invalid option value: #{name} must be an integer greater than zero"
  end
end
