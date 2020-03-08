defmodule Prisoners.Tournament do
  @moduledoc """
  Contains data about a specific tournament.
  """

  alias Prisoners.Tournament

  @type t :: %__MODULE__{
          pid: pid,
          started_at: binary,
          finished_at: binary,
          hostname: String.t(),
          app_version: String.t(),
          players_count: integer,
          players_map: map,
          faceoffs: list,
          meta: map
        }

  defstruct pid: nil,
            started_at: nil,
            finished_at: nil,
            hostname: nil,
            app_version: nil,
            players_count: 0,
            players_map: %{},
            faceoffs: [],
            meta: %{}

  def new(_players) do
    %Tournament{
      started_at: DateTime.utc_now(),
      hostname: hostname()
      #            players: players
    }
  end

  defp hostname do
    :inet.gethostname()
    |> elem(1)
    |> to_string()
  end
end
