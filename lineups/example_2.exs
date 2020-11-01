alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect, TitForTat}
alias Prisoners.RuleEngines.Simple

alias Prisoners.Reports.Summary

results = Prisoners.compete([
#  {AlwaysCooperate, [n: 10]},
  {AlwaysCooperate, []},
  {AlwaysDefect, [n: 9]},
#  {TitForTat, []},
], Simple, rounds: 3, n: 1)


Summary.report(results)

