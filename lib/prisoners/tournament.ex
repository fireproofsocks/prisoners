defmodule Prisoners.Tournament do
  @moduledoc """
  Contains data about a specific tournament.
  """

  alias Prisoners.{Player, FaceOff, Round, Tournament}

  @type t :: %__MODULE__{
          id: identifier,
          started_at: DateTime.t,
          finished_at: DateTime.t,
          hostname: String.t(),
          app_version: String.t(),
          players_count: integer,
          players_map: %{required(identifier) => Player.t},
          player_ids: [identifier],
          faceoffs: [FaceOff.t],
          rounds: [Round.t],
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
            players_map: %{},
            player_ids: [],
            faceoffs: [],
            rounds: [],
            rules_module: nil,
            response_count_by_type: %{},
            meta: %{}

  @spec new(players :: [{module, keyword}], rules_module :: module, opts :: keyword) :: Tournament.t
  def new(players, rules_module, opts) do
    {player_ids, players_map} = reference_players(players)
    %Tournament{
      id: make_ref(),
      started_at: DateTime.utc_now(),
      hostname: hostname(),
      players_map: players_map,
      player_ids: player_ids,
      faceoffs: [],
      rules_module: rules_module,
      meta: opts
    }
  end

  # Converts a list of player modules + options to a map
  defp reference_players(players) do
    Enum.map_reduce(players, %{}, fn {module, opts}, acc ->
      case Code.ensure_loaded(module) do
        {:error, reason} -> raise "Module not compiled: #{inspect(module)}. Reason: #{reason}"
        _ -> player = Player.new(module, opts) # todo: check implements behavior?
            {player.id, Map.put(acc, player.id, player)}
      end
    end)
  end

  defp hostname do
    :inet.gethostname()
    |> elem(1)
    |> to_string()
  end

  @doc """
  Retrieves the `%Player{}` struct for the given player identifier.
  """
  @spec player(tournament :: Tournament.t, player_ref :: identifier) :: Player.t
  def player(tournament, player_ref) do
    get_in(tournament, [Access.key(:players_map), Access.key(player_ref)])
  end
end
