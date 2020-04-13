defmodule Prisoners.Round do
  @moduledoc """
  Holds information about a single round
  """

  alias Prisoners.{FaceOff, Round}

  @type t :: %__MODULE__{
          n: integer,
          started_at: DateTime.t(),
          finished_at: DateTime.t(),
          response_count_by_type: %{required(atom) => integer},
          faceoffs_count: integer,
          faceoffs: [FaceOff.t()]
        }

  defstruct n: 0,
            started_at: nil,
            finished_at: nil,
            response_count_by_type: %{},
            faceoffs_count: 0,
            faceoffs: []

  def new do
    %Round{
      started_at: DateTime.utc_now()
    }
  end

  def finish(round) do
    round
    |> Map.put(:finished_at, DateTime.utc_now())
  end
end
