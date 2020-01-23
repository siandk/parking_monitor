defmodule ParkMon.AreaSupervisor do
  alias ParkMon.Monitor
  use Supervisor

  def start_link(init_arg, {:name, name}) do
    Supervisor.start_link(__MODULE__, [init_arg, name], name: name)
  end

  def init([_args, name]) do
    children = make_children(200, [], name)
    Supervisor.init(children, strategy: :one_for_one)
  end

  defp make_children(0, list, _name), do: list
  defp make_children(num, list, name) do
    monitor = build_monitor(num, name)
    make_children(num - 1, list ++ [monitor], name)
  end
  defp build_monitor(num, area_name) do
    monitor_name = String.to_atom(Atom.to_string(area_name) <> Integer.to_string(num))
    state = %{spots: Enum.random(5..15), location: area_name, occupied: [], name: monitor_name}
    Supervisor.child_spec({Monitor, state}, id: monitor_name)
  end
end
