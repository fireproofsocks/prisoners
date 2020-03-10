defmodule Prisoners.Strategies.Random do
  @moduledoc """
  This strategy will choose a random response; 50% of the time it will cooperate, 50% of the time it will defect.
  """

  alias Prisoners.Player

  @behaviour Player

  @impl Player
  def respond(_opponent_ref, _tournament),
      do: [:defect, :cooperate]
          |> Enum.shuffle()
          |> hd()

end
