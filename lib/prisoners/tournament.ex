defmodule Prisoners.Tournament do
  @moduledoc """
  Contains data about a specific tournament.
  """

  alias Prisoners.{Player, Round, Tournament}

  @type t :: %__MODULE__{
          id: identifier,
          name: String.t(),
          started_at: DateTime.t(),
          finished_at: DateTime.t(),
          hostname: String.t(),
          app_version: String.t(),
          players_count: integer,
          rounds_count: integer,
          players_map: %{
            required(identifier) => Player.t()
          },
          player_ids: [identifier],
          rounds: [Round.t()],
          rules_module: module,
          response_count_by_type: %{
            required(atom) => integer
          },
          meta: map
        }

  defstruct id: nil,
            name: "",
            started_at: nil,
            finished_at: nil,
            hostname: nil,
            app_version: nil,
            players_count: 0,
            rounds_count: 0,
            players_map: %{},
            player_ids: [],
            rounds: [],
            rules_module: nil,
            response_count_by_type: %{},
            meta: %{}

  @doc """
  Create a new tournament with the given list of players, governed by the given rules module.

  Options
  - `i` : integer used when playing multiple tournaments
  - `n` : integer to indicate how many rounds should be played. Default: `1`
  """
  @spec new(players :: [{module, keyword}], rules_module :: module, opts :: keyword) ::
          Tournament.t()
  def new(players, rules_module, opts \\ []) do
    ensure_loaded(rules_module)

    players_map = reference_players(players)
    player_ids = Map.keys(players_map)
    i = Keyword.get(opts, :i, 1)
    n = Keyword.get(opts, :n, 1)

    %Tournament{
      id: self(),
      name: get_tournament_nickname(i, n),
      started_at: DateTime.utc_now(),
      hostname: hostname(),
      app_version: app_version(),
      players_count: length(player_ids),
      players_map: players_map,
      player_ids: player_ids,
      rules_module: rules_module,
      meta: opts
    }
  end

  defp get_tournament_nickname(i, n) do
    "#{i} of #{n}"
  end

  @doc """
  Marks a tournament complete, adding summary data.
  """
  def finish(%Tournament{} = tournament) do
    tournament
    |> Map.put(:rounds_count, length(tournament.rounds))
    |> Map.put(:finished_at, DateTime.utc_now())
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
    Enum.reduce(
      players,
      %{},
      fn {module, opts}, acc ->
        ensure_loaded(module)
        {n, opts} = get_n(Keyword.pop(opts, :n, 1))

        Enum.reduce(
          1..n,
          acc,
          fn i, acc ->
            opts = Keyword.put(opts, :i, i)
            player = Player.new(module, opts)
            Map.put(acc, player.id, player)
          end
        )
      end
    )
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
  Remembering the encounter updates the inboxes and outboxes of both players involved in the encounter. Remembering is how
  each player knows what they did to another player and what other players did to them.

  It is up to the active Rules Engine to determine whether a response is valid or not.

  The given responses are prepended to the outbox and inbox lists so the most recent responses are the first items in each list.

  `resp1` is the response given by player 1 (`pid1`).
  `resp2` is the response given by player 2 (`pid2`).

  After remembering:

  Player 1's outbox will have a key for Player 2's PID, and it will contain a list with `response1` as the first item
  (i.e. the response sent from Player 1 to Player 2)

  Player 1's inbox will have a key for Player 2's PID, and it will contain a list with `response2` as the first item.
  (i.e. the response that was received by Player 1 from Player 2)

  And vice versa for Player 2.
  """
  def remember_encounter(%Tournament{} = tournament, pid1, pid2, resp1, resp2) do
    tournament
    |> update_in(
      [Access.key(:players_map), Access.key(pid1), Access.key(:outbox), Access.key(pid2, [])],
      &[resp1 | &1]
    )
    |> update_in(
      [Access.key(:players_map), Access.key(pid1), Access.key(:inbox), Access.key(pid2, [])],
      &[resp2 | &1]
    )
    |> update_in(
      [Access.key(:players_map), Access.key(pid2), Access.key(:outbox), Access.key(pid1, [])],
      &[resp2 | &1]
    )
    |> update_in(
      [Access.key(:players_map), Access.key(pid2), Access.key(:inbox), Access.key(pid1, [])],
      &[resp1 | &1]
    )
  end

  @doc """
  Retrieves the given `attribute` from the given player (identified by its PID).
  """
  def player(%Tournament{} = tournament, player_pid, attribute) do
    get_in(tournament, [Access.key(:players_map), Access.key(player_pid), Access.key(attribute)])
  end

  @doc """
  Retrieves a player (identified by its PID).
  """
  def player(%Tournament{} = tournament, player_pid) do
    get_in(tournament, [Access.key(:players_map), Access.key(player_pid)])
  end

  @doc """
  Increments a player's score by the specified `points` (this may be positive or negative).
  The current rules engine determines whether or not the player's status is one which allows it to be updated.
  For example, disqualified players will not have their scores updated.

  Returns the updated tournament struct.
  """
  @spec increment_score(Tournament.t(), pid, number) :: %Tournament{}
  def increment_score(%Tournament{} = tournament, player_pid, points) when is_number(points) do
    update_in(
      tournament,
      [Access.key(:players_map), Access.key(player_pid), Access.key(:score)],
      &(&1 + points)
    )
  end

  @doc """
  Updates a player (identified by its PID) to the specified `status`.
  """
  def update_status(%Tournament{} = tournament, player_pid, status) when is_atom(status) do
    put_in(
      tournament,
      [Access.key(:players_map), Access.key(player_pid), Access.key(:status)],
      status
    )
  end

  @doc """
  Puts the `round` into the current tournament, returns the updated tournament struct.
  This prepends the given `round` into the list of rounds so that the most recent round is the first item in the list.
  """
  @spec put_round(Tournament.t(), Round.t()) :: %Tournament{}
  def put_round(%Tournament{} = tournament, %Round{} = round) do
    %Tournament{tournament | rounds: [round | tournament.rounds]}
  end
end
