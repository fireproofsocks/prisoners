defmodule Prisoners.Report do
  @moduledoc """
  This defines the callbacks for any module wishing to implement a `c:report/2` function.
  Multiple reporting modules may be strung together, e.g. if you wish to read a quick summary
  but you also want to save detailed JSON records for later evaluation.
  """
  alias Prisoners.Tournament

  @doc """
  The function that implements this callback should take whatever actions needed to satisfy the report,
  and when finished, it should return the _original_ unmodified input so that additional reporting
  modules may be chained together.
  """
  @callback report(tournaments :: [Tournament.t()], opts :: keyword) :: [Tournament.t()]

  @doc """
  Justifies a string for centering it in a terminal of the given `width` (default 80).
  """
  @spec justify(string :: String.t(), width :: integer) :: String.t()
  def justify(string, width \\ 80) do
    half_screen = div(width, 2)
    half_string = div(String.length(string), 2)
    {left, right} = String.split_at(string, half_string)
    String.pad_leading(left, half_screen, " ") <> String.pad_trailing(right, half_screen, " ")
  end

  def time_elapsed(%DateTime{} = start_datetime, %DateTime{} = end_datetime) do
    to_hh_mm_ss(DateTime.to_unix(end_datetime) - DateTime.to_unix(start_datetime))
  end

  @doc """
  Convert seconds to HH:MM:SS format for readability.
  See https://nickjanetakis.com/blog/formatting-seconds-into-hh-mm-ss-with-elixir-and-python
  """

  def to_hh_mm_ss(seconds) when seconds >= 3600 do
    h = div(seconds, 3600)

    m =
      seconds
      |> rem(3600)
      |> div(60)
      |> pad_int()

    s =
      seconds
      |> rem(3600)
      |> rem(60)
      |> pad_int()

    "#{h}:#{m}:#{s}"
  end

  def to_hh_mm_ss(seconds) do
    m = div(seconds, 60)

    s =
      seconds
      |> rem(60)
      |> pad_int()

    "#{m}:#{s}"
  end

  defp pad_int(int, padding \\ 2) do
    int
    |> Integer.to_string()
    |> String.pad_leading(padding, "0")
  end
end
