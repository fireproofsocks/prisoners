defmodule Prisoners.Reports.Summary do
  @moduledoc """
  This module will output a simple high-level overview of the tournaments.
  """
  alias Prisoners.Report

  #    alias IO.ANSI

  @behaviour Report

  @impl Report
  def report(tournaments, _opts \\ []) do
    tournaments
    |> main_run_heading()
    |> Enum.map(&tournament_detail/1)
  end

  defp main_run_heading(tournaments) do
    IO.puts(
      IO.ANSI.blue_background() <>
        IO.ANSI.bright() <>
        Report.justify("Prisoner's Dilemma Tournament Summary") <>
        IO.ANSI.default_background() <> IO.ANSI.normal()
    )

    IO.puts("Concurrent Tournaments: #{length(tournaments)}")

    IO.puts(IO.ANSI.reset())
    tournaments
  end

  defp tournament_detail(tournament) do
    tournament
    |> tournament_heading()
    |> tournament_stats()

    #    IO.inspect(tournament)
    #    tournament
  end

  defp tournament_heading(tournament) do
    IO.puts(
      #        "Tournament #{inspect(tournament.id)}" <>
      IO.ANSI.yellow() <>
        "Tournament #{tournament.name}" <>
        IO.ANSI.reset()
    )

    tournament
  end

  defp tournament_stats(tournament) do
    IO.puts("#{tournament.players_count} players in #{tournament.rounds_count} rounds")
    IO.puts("Start: #{tournament.started_at}")
    IO.puts("Finish: #{tournament.finished_at}")
    IO.puts("Duration: #{Report.time_elapsed(tournament.started_at, tournament.finished_at)}")

    tournament
    |> players_to_rows()
    |> TableRex.quick_render!(["Name", "Module", "Score"])
    |> IO.puts()

    IO.puts("")
    tournament
  end

  defp players_to_rows(tournament) do
    tournament.players_map
    |> Map.values()
    |> Enum.map(fn x ->
      #      [inspect(x.id), x.module, x.score]
      [x.name, x.module, x.score]
    end)
  end
end
