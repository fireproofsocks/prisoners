defmodule Prisoners.RuleEngines.Simple do
  @moduledoc """
  This is a basic implementation of the original tournament idea: the important part is that defection is incentivized,
  regardless of the other players's response.

  1 of 2 possible responses (following the verbiage from the original discussion of the
  [Prisoner's Dilemma](https://en.wikipedia.org/wiki/Prisoner%27s_dilemma#Strategy_for_the_prisoner's_dilemma) game):

  - `:defect` : save your own skin at the other's expense
  - `:cooperate` : work together


  Simple scoring as follows:


  |              | B cooperates   | B defects      |
  | -----------: | ---------------| ---------------|
  | A cooperates | A: + 1; B: + 1 | A: - 1; B: + 2 |
  | A defects    | A: + 2; B: - 1 |   No points    |

  There is no elimination of bad strategies between multiple tournament iterations
  and there is no reproduction of winning player strategies.
  """
  alias Prisoners.Rules
  use Rules

  #  @impl Rules
  #  def after_faceoff(player, _faceoff, _tournament), do: [player]
  #
  #  @impl Rules
  #  def after_round(player, _faceoff, _tournament), do: [player]

  @impl Rules
  def calculate_score(_pid1, _pid2, faceoff, _tournament) do
    lookup_score(faceoff.player1_response, faceoff.player2_response)
  end

  @spec lookup_score(
          player_response :: Prisoners.response(),
          opponent_response :: Prisoners.response()
        ) :: number
  defp lookup_score(:cooperate, :cooperate), do: {1, 1}
  defp lookup_score(:cooperate, :defect), do: {-1, 2}
  defp lookup_score(:defect, :cooperate), do: {2, -1}
  defp lookup_score(:defect, :defect), do: {0, 0}
end
