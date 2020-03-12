alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}
alias Prisoners.RuleEngines.Simple

Prisoners.compete([{AlwaysCooperate, []}, {AlwaysDefect, []},], Simple, rounds: 3)