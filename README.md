# Prisoners (aka Prisoner's Dilemma )

This is a programmatic exploration to test various strategies for the [Prisoner's Dilemma](https://en.wikipedia.org/wiki/Prisoner%27s_dilemma#Strategy_for_the_prisoner's_dilemma) in a tournament like the one conceived by [Robert Axelrod](https://cs.stanford.edu/people/eroberts/courses/soco/projects/1998-99/game-theory/axelrod.html) in 1980.

The idea for this package came after hearing the Radiolab podcast episode [Tit for Tat](https://www.wnycstudios.org/podcasts/radiolab/segments/104010-one-good-deed-deserves-another).

## Installation and Usage Overview

1. [Install Elixir](https://elixir-lang.org/install.html).

2. [Create an Elixir application using Mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html#our-first-project).

3. Add `prisoners` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prisoners, "~> 1.0.0"}
  ]
end
```
4. Update your dependencies: `mix deps.get`

5. Create a tournament.

6. Run it. You can run scripts in the context of your mix project with `mix run`, e.g. `mix run strategies/example.exs`. See `mix help run` for more information.

## Competing

When two competing strategies encounter one another during a tournament competition they can choose any possible response 
that is allowed by the rule engine.  

It is up to the rules engine to determine exactly how the round is played; for example, an engine may or may not force 
encounters between all participating players. See the `Rules.play_round/1` callback.


## Links

https://www.wnycstudios.org/podcasts/radiolab/segments/104010-one-good-deed-deserves-another
https://cs.stanford.edu/people/eroberts/courses/soco/projects/1998-99/game-theory/axelrod.html
https://www.nature.com/articles/s41598-018-20426-w


http://erlang.org/doc/design_principles/des_princ.html#supervision-trees
