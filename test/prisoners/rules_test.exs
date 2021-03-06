defmodule Prisoners.RulesTest do
  use ExUnit.Case
  alias Prisoners.{FaceOff, Rules}

  describe "summarize_faceoff_responses_by_type/1" do
    test "counts correctly" do
      assert %{cooperate: 1, defect: 5} ==
               Rules.summarize_faceoff_responses_by_type([
                 %FaceOff{
                   player1_response: :cooperate,
                   player2_response: :defect
                 },
                 %FaceOff{
                   player1_response: :defect,
                   player2_response: :defect
                 },
                 %FaceOff{
                   player1_response: :defect,
                   player2_response: :defect
                 }
               ])
    end
  end

  describe "all_pairs/1" do
    test "all combinations found" do
      assert [["a", "b"], ["a", "c"], ["a", "d"], ["b", "c"], ["b", "d"], ["c", "d"]] ==
               Rules.all_pairs(["a", "b", "c", "d"])
    end
  end
end
