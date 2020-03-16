alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}
alias Prisoners.RuleEngines.Simple

results = Prisoners.compete([{AlwaysCooperate, []}, {AlwaysDefect, []},], Simple, rounds: 3, n: 2)
IO.inspect(results)