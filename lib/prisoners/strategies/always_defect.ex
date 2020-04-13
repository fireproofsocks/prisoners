defmodule Prisoners.Strategies.AlwaysDefect do
  @moduledoc """
  This strategy will always defect (i.e. always retaliate). It is the exact opposite of the `AlwaysCooperate` strategy.
  """

  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_opponent_pid, _tournament), do: :defect
end
