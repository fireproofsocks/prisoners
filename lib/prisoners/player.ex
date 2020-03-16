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
          inbox: %{required(identifier) => [Prisoners.response()]},
          outbox: %{required(identifier) => [Prisoners.response()]},
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
  @callback respond(opponent :: Player.t(), tournament :: Tournament.t()) :: Prisoners.response()

  @doc """
  This callback is called after a completed Tournament round for each of the players competing in the `Tournament`.

  Depending on the rules engine implementation, this may cause a `Player` to be knocked out of the tournament
  or it may allow the `Player` to reproduce and return additional variants of itself.

  This function has no effect when a tournament has only one round.

  A default implementation is provided.
  """
  @callback after_round(player :: Player.t(), tournament :: Tournament.t()) :: [Player.t()]

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

  @doc """
  Create a new `%Player{}` struct.

  Options:

  - `n` (integer) the number of instances to create. Default: `1`
  """
  @spec new(player_module :: module, opts :: keyword) :: Player.t()
  def new(player_module, opts \\ []) do
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
