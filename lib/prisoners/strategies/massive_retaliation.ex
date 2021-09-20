defmodule Prisoners.Strategies.MassiveRetaliation do
  @moduledoc """
  This unforgiving strategy will cooperate until the first time it is crossed:
  afterwards every response from it will be to defect (i.e. retaliate massively
  and never forget the people who wronged it).

  ## Rules Engine Compatibility

  This module is compatible with the `Prisoners.RuleEngines.Simple` rules engine.
  """
  # TODO
end
