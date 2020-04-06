defmodule PrisonersTest do
  use ExUnit.Case
  doctest Prisoners

  describe "compete/3" do
    test "raises when players is not a list" do
      assert_raise FunctionClauseError, fn -> Prisoners.compete("not_a_list", nil) end
    end

    test "raises when rules_module is not an atom" do
      assert_raise FunctionClauseError, fn -> Prisoners.compete([], "not_atom") end
    end

    test "raises when n not positive integer" do
      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, n: -1)
      end

      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, n: :invalid)
      end

      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, n: "nope")
      end
    end

    test "raises when rounds not positive integer" do
      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, rounds: -1)
      end

      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, rounds: :invalid)
      end

      assert_raise RuntimeError, fn ->
        Prisoners.compete([], Prisoners.RuleEngines.Simple, rounds: "nope")
      end
    end
  end
end
