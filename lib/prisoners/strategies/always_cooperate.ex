defmodule Prisoners.Strategies.AlwaysCooperate do
  @moduledoc """
  This strategy will always cooperate (i.e. will always be nice), no matter the opponent and no matter what has happened
  in the tournament.
  """
  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_opponent_ref, _tournament), do: :cooperate
end
