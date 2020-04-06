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
end
