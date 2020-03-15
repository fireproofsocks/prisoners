defmodule Prisoners.Player do
  @moduledoc """
  Defines a single player (i.e. a competitor).
  """

  alias Prisoners.Player
  alias Prisoners.Tournament

  @type t :: %__MODULE__{
               id: identifier,
               module: module,
               points: integer,
               inbox: %{required(identifier) => [Prisoners.response]},
               outbox: %{required(identifier) => [Prisoners.response]},
               meta: map
             }

  defstruct id: nil,
            module: nil,
            points: 0,
            inbox: %{},
            outbox: %{},
            meta: %{}

  @doc """
  In order for a player to play, it must respond with either `:cooperate` or `:defect` when it faces off with another
  player.
  """
  @callback respond(opponent :: Player.t, tournament :: Tournament.t) :: Prisoners.response

  # You can't do this if you want to run the faceoffs concurrently / in parallel!
#  @doc """
#  This callback _may_ be called after a faceoff between two players. It is up to the Rules Engine to determine whether
#  or not the player will get the opportunity to modify itself.
#
#  The implementation of this callback can have the effect of a player introducing copies of itself (i.e. reproducing),
#  a player modifying its configuration, or even a player taking itself out of the tournament.
#
#  A default implementation is provided.
#  """
#  @callback after_faceoff(player :: Player.t, tournament :: Tournament.t) :: [Player.t]

  @doc """
  This callback is called after a completed Tournament round for each of the players competing in the `Tournament`.

  Depending on the rules engine implementation, this may cause a `Player` to be knocked out of the tournament
  or it may allow the `Player` to reproduce and return additional variants of itself.

  This function has no effect when a tournament has only one round.

  A default implementation is provided.
  """
  @callback after_round(player :: Player.t, tournament :: Tournament.t) :: [Player.t]

  defmacro __using__(_opts) do
    quote do
      @behaviour Player

#      @impl Player
#      def after_faceoff(player, _tournament), do: [player]

      @impl Player
      def after_round(player, _tournament), do: [player]

      # A default implementation is provided, but a Strategy may implement their own
#      defoverridable after_faceoff: 2, after_round: 2
      defoverridable after_round: 2
    end
  end

  def new(player_module, opts) do
    %Player{
      id: make_ref(),
      module: player_module,
      points: 0,
      inbox: %{},
      outbox: %{},
      meta: opts
    }
  end
end
