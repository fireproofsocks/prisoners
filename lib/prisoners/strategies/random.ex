defmodule Prisoners.Strategies.Random do
  @moduledoc """
  This strategy will choose a random response; 50% of the time it will cooperate,
  50% of the time it will defect.

  ## Rules Engine Compatibility

  This module is compatible with the `Prisoners.RuleEngines.Simple` rules engine.
  """

  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_my_pid, _opponent_ref, _tournament),
    do:
      [:defect, :cooperate]
      |> Enum.shuffle()
      |> hd()
end
