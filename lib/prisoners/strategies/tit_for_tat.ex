defmodule Prisoners.Strategies.TitForTat do
  @moduledoc """
  This strategy will start with a default response, but after that, it will
  simply do whatever the opponent has done to it (a.k.a. an eye for an eye or...
  tit for tat).
  """

  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_opponent_ref, _tournament), do: :todo
end
