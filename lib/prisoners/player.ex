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
  @callback respond(opponent :: identifier, tournament :: Tournament.t) :: Prisoners.response

  defmacro __using__(_opts) do
    quote do
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
