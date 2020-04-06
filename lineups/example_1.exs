alias Prisoners.Strategies.{AlwaysCooperate, AlwaysDefect}
alias Prisoners.RuleEngines.Simple

alias Prisoners.Reports.Summary

results = Prisoners.compete([{AlwaysCooperate, []}, {AlwaysDefect, []},], Simple, rounds: 3, n: 2)


Summary.report(results)

#IO.ANSI.yellow()
#IO.puts("Hello?")