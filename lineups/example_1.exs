alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}
alias Prisoners.RuleEngines.Simple

alias Prisoners.Reports.Summary

results = Prisoners.compete([{AlwaysCooperate, [n: 9]}, {AlwaysDefect, []},], Simple, rounds: 3, n: 2)


Summary.report(results)

