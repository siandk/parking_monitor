defmodule ParkMon.Store do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: :store)
  end

  def init(_args) do
    :ets.new(:store, [:bag, :public, :named_table])
    {:ok, :store}
  end
  def handle_call({:create, {monitor, area, license_plate}}, _from, state) do
    :ets.insert(:store, {monitor, area, license_plate})
    {:reply, {:ok, license_plate}, state}
  end
  def handle_call({:lookup, data}, _from, state) do
    case lookup(data) do
      {:ok, result} -> {:reply, {:ok, result}, state}
      {:error, msg} -> {:reply, {:error, msg}, state}
    end
  end
  def handle_cast({:delete, license_plate}, state) do
    :ets.match_delete(:store, {:"$1", :"$2", license_plate})
    {:noreply, state}
  end
  defp lookup({:monitor, data}) when is_atom(data) do
    {:ok, :ets.match(:store, {data, :_, :"$3"})}
  end
  defp lookup({:area, data}) when is_atom(data) do
    {:ok, :ets.match(:store, {:"$1", data, :"$3"})}
  end
  defp lookup({:plate, data}) when is_binary(data) do
    {:ok, :ets.match(:store, {:"$1", :"$2", data})}
  end
  defp lookup(_) do
    {:error, "Operation not supported"}
  end
end
