defmodule Prisoners.Strategies.TitForTat do
  @moduledoc """
  This strategy will start with a default response, but after that, it will
  simply do whatever the opponent has done to it (a.k.a. an eye for an eye or...
  tit for tat).

  ## Rules Engine Compatibility

  This module is compatible with the `Prisoners.RuleEngines.Simple` rules engine.
  """

  alias Prisoners.Player
  alias Prisoners.Tournament

  use Player

  @impl Player
  def respond(my_pid, opponent_pid, tournament) do
    %Player{outbox: outbox} = Tournament.player(tournament, opponent_pid)
    #    IO.inspect(tournament)
    #    IO.inspect(player)
    #    IO.puts("PID: #{self()}")
    what_they_did_to_me = Map.get(outbox, my_pid, [])

    case what_they_did_to_me do
      [] ->
        IO.puts("No history with them...")
        :cooperate

      [their_last_response | _older_responses] ->
        IO.puts("They did #{their_last_response}")
        their_last_response
    end
  end
end
