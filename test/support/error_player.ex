defmodule Prisoners.ErrorPlayer do
  @moduledoc """
  This player module misbehaves and returns invalid responses.
  """

  alias Prisoners.Player

  use Player

  @impl Player
  def respond(_opponent_ref, _tournament), do: "Invalid response!"
end
