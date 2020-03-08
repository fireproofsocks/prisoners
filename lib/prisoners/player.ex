defmodule Prisoners.Player do
  @moduledoc """
  Defines a single player (i.e. a competitor).
  """

  alias Prisoners.Player

  defstruct pid: nil,
            module: nil,
            points: 0,
            inbox: %{},
            outbox: %{},
            meta: %{}

  def new(player, opts) do
    %Player{
      module: player,
      meta: opts
    }
  end
end
