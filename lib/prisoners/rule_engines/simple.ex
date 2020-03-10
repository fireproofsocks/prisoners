defmodule Prisoners.RuleEngines.Simple do
  @moduledoc """
  Basic implementation of the original tournament idea.
  Simple scoring.
  No elimination of bad strategies between multiple tournament iterations.
  """
  alias Prisoners.Rules

  @behaviour Rules

  @impl Rules
  def continue?(_, _), do: true
end
