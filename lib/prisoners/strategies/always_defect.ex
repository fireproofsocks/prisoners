defmodule Prisoners.Strategies.AlwaysDefect do
  @moduledoc """
  This strategy will always defect (i.e. always retaliate). It is the exact
  opposite of the `Prisoners.Strategies.AlwaysCooperate` strategy.

  ## Rules Engine Compatibility

  This module is compatible with the `Prisoners.RuleEngines.Simple` rules engine.
  """

  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_my_pid, _opponent_pid, _tournament), do: :defect
end
