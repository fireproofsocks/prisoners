defmodule Prisoners.Player do
  @moduledoc """
  Defines a single player (i.e. a competitor) inside its own process.
  """

  alias Prisoners.Player
  alias Prisoners.Tournament

  @type t :: %__MODULE__{
          id: identifier,
          module: module,
          score: integer,
          inbox: %{
            required(identifier) => [Prisoners.response()]
          },
          outbox: %{
            required(identifier) => [Prisoners.response()]
          },
          meta: map
        }

  defstruct id: nil,
            module: nil,
            score: 0,
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

  This callback is optional: a default implementation is provided.
  """
  @callback after_round(player :: Player.t(), tournament :: Tournament.t()) :: [Player.t()]

  @doc """
  Defines the initial state that a player process will have.
  This callback is optional: a default implementation is provided.
  """
  @callback initial_state(opts :: keyword) :: map

  defmacro __using__(_opts) do
    quote do
      use GenServer

      @behaviour Player

      #      @impl Player
      #      def after_faceoff(player, _tournament), do: [player]

      def start_link(init_args) do
        GenServer.start_link(__MODULE__, init_args, [])
      end

      # File away for reference the details of a faceoff: what I did to them,
      # what they did to us
      def remember_encounter(my_pid, their_pid, my_response, their_response) do
        GenServer.call(my_pid, {:remember, their_pid, my_response, their_response})
      end

      def inbox(my_pid, opponent_pid) do
        GenServer.call(my_pid, {:inbox, opponent_pid})
      end

      def outbox(my_pid, opponent_pid) do
        GenServer.call(my_pid, {:outbox, opponent_pid})
      end

      def increment_score(my_pid, points) do
        GenServer.call(my_pid, {:inc_score, points})
      end

      def get_score(my_pid) do
        GenServer.call(my_pid, {:get_score})
      end

      # GenServer callbacks
      def init(opts) do
        Process.flag(:trap_exit, true)
        {:ok, initial_state(opts)}
      end

      @doc """
        %{
          inbox: %{
            <pid_x>: []
          },
          outbox: %{
            <pid_x>: []
          },
        }
      """
      # iex> get_in(my_struct, [Access.key(:x), Access.key(:y, "my_default")])
      # "this thing"
      def handle_call({:remember, their_pid, my_response, their_response}, _from, state) do
        outbox = Map.get(state, :outbox, %{})
        responses_sent_to_this_player = Map.get(outbox, their_pid, [])
        responses_sent_to_this_player = [my_response | responses_sent_to_this_player]
        outbox = Map.put(outbox, their_pid, responses_sent_to_this_player)

        inbox = Map.get(state, :inbox, %{})
        responses_received_from_this_player = Map.get(inbox, their_pid, [])

        responses_received_from_this_player = [
          their_response | responses_received_from_this_player
        ]

        inbox = Map.put(inbox, their_pid, responses_received_from_this_player)

        {
          :reply,
          :ok,
          state
          |> Map.put(:inbox, inbox)
          |> Map.put(:outbox, outbox)
        }
      end

      def handle_call({:inbox, their_pid}, _from, state) do
        #        inbox = Map.get(state, :inbox, %{})
        {
          :reply,
          state
          |> Map.get(:inbox, %{})
          |> Map.get(their_pid, []),
          state
        }
      end

      def handle_call({:outbox, their_pid}, _from, state) do
        #        inbox = Map.get(state, :inbox, %{})
        {
          :reply,
          state
          |> Map.get(:outbox, %{})
          |> Map.get(their_pid, []),
          state
        }
      end

      def handle_call({:inc_score, points}, _from, state) when is_number(points) do
        score = Map.get(state, :score, 0)

        {
          :reply,
          :ok,
          Map.put(state, :score, score + points)
        }
      end

      def handle_call({:get_score}, _from, state) do
        {
          :reply,
          Map.get(state, :score, 0),
          state
        }
      end

      #      def handle_call({:inbox, key, value, ttl}, _from, state) do
      #        {:reply, :ok, Map.put(state, key, value)}
      #      end
      #
      #      def handle_call({:outbox, key}, _from, state) do
      #        {:reply, :ok, Map.get(state, key)}
      #      end

      @impl Player
      def initial_state(_opts), do: %{inbox: %{}, outbox: %{}}

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
    {:ok, pid} = player_module.start_link(opts)

    %Player{
      id: pid,
      module: player_module,
      score: 0,
      inbox: %{},
      outbox: %{},
      meta: opts
    }
  end
end
