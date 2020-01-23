defmodule ParkMon.SimulatorSupervisor do
  alias ParkMon.Simulator
  use Supervisor


  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  def init(_args) do
    children = make_children(400, [])
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp make_children(0, list), do: list
  defp make_children(num, list) do
    make_children(num - 1, list ++ [Supervisor.child_spec({Simulator, []}, id: make_ref())])
  end
end
