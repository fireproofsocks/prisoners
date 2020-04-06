defmodule Prisoners.Tournament do
  @moduledoc """
  Contains data about a specific tournament.
  """

  alias Prisoners.{FaceOff, Player, Round, Tournament}

  @type t :: %__MODULE__{
          id: identifier,
          started_at: DateTime.t(),
          finished_at: DateTime.t(),
          hostname: String.t(),
          app_version: String.t(),
          players_count: integer,
          rounds_count: integer,
          concurrent_count: integer,
          players_map: %{required(identifier) => Player.t()},
          player_ids: [identifier],
          rounds: [Round.t()],
          rules_module: module,
          response_count_by_type: %{required(atom) => integer},
          meta: map
        }

  defstruct id: nil,
            started_at: nil,
            finished_at: nil,
            hostname: nil,
            app_version: nil,
            players_count: 0,
            rounds_count: 0,
            concurrent_count: 0,
            players_map: %{},
            player_ids: [],
            rounds: [],
            rules_module: nil,
            response_count_by_type: %{},
            meta: %{}

  @spec new(players :: [{module, keyword}], rules_module :: module, opts :: keyword) ::
          Tournament.t()
  def new(players, rules_module, opts \\ []) do
    ensure_loaded(rules_module)

    players_map = reference_players(players)
    player_ids = Map.keys(players_map)

    %Tournament{
      #      id: nil, # PID added once it's spawned
      #      started_at: nil, # added once it's spawned DateTime.utc_now(),
      hostname: hostname(),
      app_version: app_version(),
      players_count: length(player_ids),
      players_map: players_map,
      player_ids: player_ids,
      rules_module: rules_module,
      meta: opts
    }
  end

  # Make sure we got passed a valid module.
  defp ensure_loaded(module) do
    case Code.ensure_loaded(module) do
      {:error, reason} -> raise "Module not compiled: #{inspect(module)}. Reason: #{reason}"
      _ -> nil
    end
  end

  # Converts a list of player modules + options to a map keyed by the player's pid
  @spec reference_players([Player.t()]) :: %{required(identifier) => Player.t()}
  defp reference_players(players) do
    Enum.reduce(players, %{}, fn {module, opts}, acc ->
      ensure_loaded(module)
      {n, opts} = get_n(Keyword.pop(opts, :n, 1))

      Enum.reduce(1..n, acc, fn _, acc ->
        player = Player.new(module, opts)
        Map.put(acc, player.id, player)
      end)
    end)
  end

  @spec get_n(tuple) :: tuple
  defp get_n({n, opts}) when is_integer(n) and n > 0, do: {n, opts}

  @spec get_n(tuple) :: tuple
  defp get_n(_) do
    raise "Invalid Player option value: n must be an integer greater than zero"
  end

  defp hostname do
    :inet.gethostname()
    |> elem(1)
    |> to_string()
  end

  defp app_version do
    version =
      Application.spec(:prisoners)[:vsn]
      |> List.to_string()

    "prisoners:#{version}"
  end

  @doc """
  This function returns all possible pairs from a list (the order of the items is not significant).
  It is provided as a convenience for implementing the
  `c:Prisoners.Rules.play_round/1` functionality where a rules engine regulates the facing off of players with each other.

  ## Examples
      iex> Tournament.pairs(["a", "b", "c", "d"])
      [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]]

  """
  @spec pairs(list) :: list
  def pairs(list), do: combinations(2, list)

  # Adapted from http://rosettacode.org/wiki/Combinations#Elixir
  defp combinations(0, _), do: [[]]
  defp combinations(_, []), do: []

  defp combinations(i, [player | rest]) do
    for(list <- combinations(i - 1, rest), do: [player | list]) ++ combinations(i, rest)
  end

  @doc """
  Retrieves the `%Player{}` struct for the given player identifier.
  """
  @spec player(tournament :: Tournament.t(), player_ref :: identifier) :: Player.t()
  # TODO when is_pid(pid) do
  def player(tournament, pid) do
    get_in(tournament, [Access.key(:players_map), Access.key(pid)])
  end
end
