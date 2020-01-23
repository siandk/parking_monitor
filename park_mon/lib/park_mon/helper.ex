defmodule ParkMon.Helper do

  def string_to_atom(arg) when is_binary(arg) do
    try do
      atom = String.to_existing_atom(arg)
      {:ok, atom}
    rescue
      _ in ArgumentError -> {:error, nil}
    end
  end

  def pid_exists(name) when is_atom(name) do
    case :erlang.whereis(name) do
      :undefined -> {:error, nil}
      pid -> {:ok, pid}
    end
  end
end
