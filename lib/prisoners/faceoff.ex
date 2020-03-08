defmodule Prisoners.Faceoff do
  @moduledoc """
  Defines a single faceoff between 2 players
  """

  alias Prisoners.Faceoff

  defstruct player1_pid: nil,
            player2_pid: nil,
            player1_response: nil,
            player2_response: nil,
            player1_result: nil,
            player2_result: nil,
            player1_points_received: nil,
            player2_points_received: nil
end
