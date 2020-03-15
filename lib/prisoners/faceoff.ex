defmodule Prisoners.FaceOff do
  @moduledoc """
  Defines a single faceoff between 2 players. This structure is defined as an aid for consistent logging and reporting.
  """

  alias Prisoners.FaceOff

  @type t :: %__MODULE__{
               player1_id: identifier,
               player2_id: identifier,
               player1_response: :cooperate | :defect,
               player2_response: :cooperate | :defect,
#               player1_result: String.t,
#               player2_result: String.t,
               player1_points_received: integer,
               player2_points_received: integer,
             }

  defstruct player1_id: nil,
            player2_id: nil,
            player1_response: nil,
            player2_response: nil,
#            player1_result: nil,
#            player2_result: nil,
            player1_points_received: nil,
            player2_points_received: nil
end
