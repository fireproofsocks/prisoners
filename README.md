# Prisoners (aka Prisoner's Dilemma )

A programmatic exploration to test various strategies for the prisoner's dilemma in a tournament like the one conceived by [Robert Axelrod](https://cs.stanford.edu/people/eroberts/courses/soco/projects/1998-99/game-theory/axelrod.html).

The idea for this package came after hearing the Radiolab podcast episode [Tit for Tat](https://www.wnycstudios.org/podcasts/radiolab/segments/104010-one-good-deed-deserves-another).

## Installation

Install Elixir.
Create an app.

Add `prisoners` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prisoners, "~> 1.0.0"}
  ]
end
```

Create a tournament.
Run it.

## Competing

When two competing strategies encounter one another during a tournament competition they can choose 1 of 2 possible responses (following the verbiage from the original discussion of the [Prisoner's Dilemma](https://en.wikipedia.org/wiki/Prisoner%27s_dilemma#Strategy_for_the_prisoner's_dilemma) game):

- `:defect` : save your own skin at the other's expense
- `:cooperate` : work together

### Scoring 

The main push of the Prisoner's Dilemma is that defection always results in a better payoff than cooperation regardless of the other player's choice. How this is implemented with points is subject to interpretation.

|              | B cooperates   | B defects      |
| -----------: | ---------------| ---------------|
| A cooperates | A: + 1; B: + 1 | A: - 1; B: + 2 |
| A defects    | A: + 2; B: - 1 |   No points    |


## Links

https://www.wnycstudios.org/podcasts/radiolab/segments/104010-one-good-deed-deserves-another
https://cs.stanford.edu/people/eroberts/courses/soco/projects/1998-99/game-theory/axelrod.html
https://www.nature.com/articles/s41598-018-20426-w


http://erlang.org/doc/design_principles/des_princ.html#supervision-trees