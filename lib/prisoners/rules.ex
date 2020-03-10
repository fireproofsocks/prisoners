defmodule Prisoners.Rules do
    @moduledoc """
    Defines the interface for all rule engines.
    """
    alias Prisoners.Tournament

    @doc """
    Filters participants between multiple iterations of a tournament. When true, the player continues to the next round.
    When false, the given player reference is removed from the pool of competitors.
    This function has no effect when a tournament is run only once.
    """
    @callback continue?(player_ref :: reference, tournament :: Tournament.t) :: boolean

    # @callback filter(player_ref :: reference, tournament :: Tournament.t) :: {:continue, }
end