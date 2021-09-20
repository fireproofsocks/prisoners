defmodule Prisoners.Strategies.AlwaysCooperate do
  @moduledoc """
  This strategy will always cooperate (i.e. will always be nice), no matter the
  opponent and no matter what has happened in the tournament.

  ## Rules Engine Compatibility

  This module is compatible with the `Prisoners.RuleEngines.Simple` rules engine.
  """
  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_my_pid, _opponent_pid, _tournament), do: :cooperate
end
