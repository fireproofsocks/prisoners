defmodule Prisoners.Utils do
  @moduledoc false
  # Home to a few shared functions
  defmacro __using__(_opts) do
    quote do
      @spec ensure_pos_integer(integer, atom) :: tuple
      defp ensure_pos_integer(n, _) when is_integer(n) and n > 0, do: n

      @spec ensure_pos_integer(tuple, atom) :: tuple
      defp ensure_pos_integer(_, name) do
        raise "Invalid option value: #{name} must be an integer greater than zero"
      end
    end
  end
end
