defmodule Prisoners.Round do
  @moduledoc """
  Holds information about a single round
  """

  alias Prisoners.FaceOff

  @type t :: %__MODULE__{
          players_count_at_start: integer,
          players_count_at_finish: integer,
          response_count_by_type: %{required(atom) => integer},
          faceoffs: [FaceOff.t()]
        }

  defstruct players_count_at_start: 0,
            players_count_at_finish: 0,
            response_count_by_type: %{},
            faceoffs: []
end
