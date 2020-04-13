defmodule Prisoners.PlayerTest do
  use ExUnit.Case

  alias Prisoners.Player
  alias Prisoners.Strategies.AlwaysCooperate

  describe "new/2" do
    test "instantiate a single player" do
      assert %Player{} = Player.new(AlwaysCooperate)
    end

    test "nickname is based off of module name if no name provided" do
      assert %Player{name: "AlwaysCooperate.0"} = Player.new(AlwaysCooperate)
    end

    test "nickname suffix incorporates i" do
      assert %Player{name: "AlwaysCooperate.3"} = Player.new(AlwaysCooperate, i: 3)
    end

    test "nickname defers to explicit :name" do
      assert %Player{name: "NiceGuy.0"} = Player.new(AlwaysCooperate, name: "NiceGuy")
    end
  end

  describe "dump/1" do
    test "dump player data" do
      %Player{id: id} = Player.new(AlwaysCooperate, buzz: "me")
      assert [buzz: "me"] = AlwaysCooperate.dump(id)
    end
  end

  #  describe "handle_call/3" do
  #    test "remember" do
  #      p = Player.new(Prisoners.Strategies.AlwaysCooperate)
  #      x = p.handle_call({:remember, 123, :defect, :cooperate}, nil, %{})
  #      assert true == x
  #    end
  #  end

  #  describe "remember_encounter/4" do
  #    test "normal" do
  #      {:ok, pid} = AlwaysCooperate.start_link([])
  #      assert :ok = AlwaysCooperate.remember_encounter(pid, 123, :defect, :cooperate)
  #    end
  #  end
  #
  #  describe "inbox/2" do
  #    test "can retrieve responses received from opponent" do
  #      {:ok, pid} = AlwaysCooperate.start_link([])
  #      :ok = AlwaysCooperate.remember_encounter(pid, 123, :defect, :cooperate)
  #      assert [:cooperate] = AlwaysCooperate.inbox(pid, 123)
  #    end
  #  end
  #
  #  describe "outbox/2" do
  #    test "can retrieve responses sent to opponent" do
  #      {:ok, pid} = AlwaysCooperate.start_link([])
  #      :ok = AlwaysCooperate.remember_encounter(pid, 123, :defect, :cooperate)
  #      assert [:defect] = AlwaysCooperate.outbox(pid, 123)
  #    end
  #  end
  #
  #  describe "increment_score/2" do
  #    test "can increment score" do
  #      {:ok, pid} = AlwaysCooperate.start_link([])
  #      assert :ok = AlwaysCooperate.increment_score(pid, 42)
  #    end
  #  end
  #
  #  describe "get_score/1" do
  #    test "can retrieve score" do
  #      {:ok, pid} = AlwaysCooperate.start_link([])
  #      :ok = AlwaysCooperate.increment_score(pid, 42)
  #      :ok = AlwaysCooperate.increment_score(pid, 4)
  #      assert 46 == AlwaysCooperate.get_score(pid)
  #    end
  #  end
end
