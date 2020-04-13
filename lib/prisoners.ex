defmodule Prisoners do
  @moduledoc """
  Documentation for `Prisoners`.
  """

  alias Prisoners.{Player, Tournament}
  use Prisoners.Utils
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
  Play `n` number of tournaments using the given rules engine.

  Options:
    - `:rounds` (integer) : the number of rounds (i.e. iterations) in the tournament. Default: `1`
    - `:n` (integer) : the number of concurrent tournaments to  run. Default `1`

  """
  @spec compete(players :: [{module, keyword}], rules_module :: module, opts :: keyword) :: [
          Tournament.t()
        ]
  def compete(players, rules_module, opts \\ [])

  def compete(players, rules_module, opts) when is_list(players) and is_atom(rules_module) do
    rounds = ensure_pos_integer(Keyword.get(opts, :rounds, 1), :rounds)
    n = ensure_pos_integer(Keyword.get(opts, :n, 1), :n)
    opts = Keyword.drop(opts, [:n])
    opts = Keyword.put(opts, :n, n)

    caller = self()

    Logger.info("Starting tournament(s) with options #{inspect(opts)}")

    1..n
    |> Enum.map(fn i ->
      spawn(fn ->
        send(
          caller,
          {self(),
           players
           |> Tournament.new(rules_module, Keyword.put(opts, :i, i))
           |> rules_module.play_tournament(Keyword.put(opts, :n, rounds))}
        )
      end)
    end)
    |> Enum.map(fn pid ->
      receive do
        {^pid, tournament} ->
          Tournament.finish(tournament)
      end
    end)
  end
end
