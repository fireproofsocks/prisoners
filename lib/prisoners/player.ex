defmodule Prisoners.Player do
  @moduledoc """
  Defines a single player (i.e. a competitor) inside its own process.
  """

  alias Prisoners.Player
  alias Prisoners.Tournament

  @type t :: %__MODULE__{
          id: identifier,
          name: String.t(),
          module: module,
          score: integer,
          inbox: %{
            required(identifier) => [Prisoners.response()]
          },
          outbox: %{
            required(identifier) => [Prisoners.response()]
          },
          status: atom
        }

  defstruct id: nil,
            name: "",
            module: nil,
            score: 0,
            inbox: %{},
            outbox: %{},
            status: nil

  @doc """
  In order for a player to play, it must respond with either `:cooperate` or `:defect` when it faces off with another
  player.
  """
  @callback respond(me :: pid, opponent :: pid, tournament :: Tournament.t()) :: Prisoners.response()

  @doc """
  This callback is called after a completed Tournament round for each of the players competing in the `Tournament`.

  Depending on the rules engine implementation, this may cause a `Player` to be knocked out of the tournament
  or it may allow the `Player` to reproduce and return additional variants of itself.

  This function has no effect when a tournament has only one round.

  This callback is optional: a default implementation is provided.
  """
  @callback after_round(player :: Player.t(), tournament :: Tournament.t()) :: [Player.t()]

  #  @doc """
  #  Defines the initial state that a player process will have.
  #  This callback is optional: a default implementation is provided.
  #  """
  #  @callback initial_state(opts :: keyword) :: map

  defmacro __using__(_opts) do
    quote do
      use GenServer

      @behaviour Player

      #      @impl Player
      #      def after_faceoff(player, _tournament), do: [player]

      #      def handle_call({:inbox, key, value, ttl}, _from, state) do
      #        {:reply, :ok, Map.put(state, key, value)}
      #      end
      #
      #      def handle_call({:outbox, key}, _from, state) do
      #        {:reply, :ok, Map.get(state, key)}
      #      end

      @impl Player
      def after_round(player, _tournament), do: [player]

      # GenServer callbacks
      def start_link(init_args), do: GenServer.start_link(__MODULE__, init_args, [])

      @doc """
      Sets the inital player state
      """
      def init(state), do: {:ok, state}

      @doc """
      Gets a dump of the player's state
      """
      def dump(pid), do: GenServer.call(pid, :dump)

      def handle_call(:dump, _from, state), do: {:reply, state, state}

      # A default implementation is provided, but a Strategy may implement their own
      #      defoverridable after_faceoff: 2, after_round: 2
      defoverridable after_round: 2, init: 1
    end
  end

  @doc """
  Create a new `%Player{}` struct.

  Options represents any keyword list that you wish to pass to the player process.
  """
  @spec new(player_module :: module, opts :: keyword) :: Player.t()
  def new(player_module, opts \\ []) do
    {:ok, pid} = player_module.start_link(opts)

    name =
      opts
      |> Keyword.get(:name, "")
      |> String.trim()

    i = Keyword.get(opts, :i, 0)

    %Player{
      id: pid,
      name: get_player_nickname(name, i, player_module),
      module: player_module,
      score: 0,
      inbox: %{},
      outbox: %{},
      # defer starting status to Rules engine?
      status: :live
    }
  end

  @spec get_player_nickname(String.t(), n :: integer, atom) :: String.t()
  defp get_player_nickname("", n, player_module) do
    player_module
    |> Atom.to_string()
    |> String.split(".")
    |> Enum.reverse()
    |> hd()
    |> get_player_nickname(n, player_module)
  end

  @spec get_player_nickname(String.t(), n :: integer, atom) :: String.t()
  defp get_player_nickname(name, n, _module) do
    "#{name}.#{n}"
  end
end
