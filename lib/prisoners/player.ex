defmodule Prisoners.Player do
  @moduledoc """
  Defines a single player (i.e. a competitor).
  """

  alias Prisoners.Player
  alias Prisoners.Tournament

  @type t :: %__MODULE__{
               id: identifier,
               module: atom,
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
  In order for a player to play, it must respond with either `:cooperate` or `:defect`.
  """
  @callback respond(opponent :: Player.t, tournament :: Tournament.t) :: Prisoners.response

  @doc """
  This function may be implemented by more advanced strategies that wish to define how exactly a `Player` reproduces.
  Not all rules engines call this function, and different rules engines may call this function at different times.
  """
  @callback reproduce(player :: Player.t, tournament :: Tournament.t) :: [Player.t]

  defmacro __using__(_opts) do
    quote do
      @behaviour Player

      @impl Player
      def reproduce(player, _tournament), do: [player]
      # A default implementation is provided, but a Strategy may implement their own
      defoverridable reproduce: 2
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
