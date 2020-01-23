defmodule ParkMonClient.ClientUpdater do
  alias ParkMonClientWeb.Endpoint
  use GenServer
  require Logger

  def start_link(monitor_name) do
    updater_name = String.to_atom(monitor_name <> "-updater")
    GenServer.start_link(__MODULE__, monitor_name, name: updater_name)
  end

  def init(monitor_name) do
    :timer.send_interval(250, :broadcast)
    {:ok, monitor_name}
  end

  def handle_info(:broadcast, monitor_name) do
    broadcast(monitor_name)
    {:noreply, monitor_name}
  end

  defp broadcast(monitor_name) do
    {:ok, {plate_list, total_spots}} = GenServer.call(String.to_existing_atom(monitor_name), :occupied)
    Endpoint.broadcast!("room:"<>monitor_name, "occupied", %{msg: plate_list, room: "room:"<>monitor_name, count: "#{length(plate_list)}/#{total_spots}"})
  end
end
