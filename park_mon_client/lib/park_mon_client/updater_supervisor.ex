defmodule ParkMonClient.UpdaterSupervisor do
  alias ParkMonClient.ClientUpdater
  use DynamicSupervisor
  require Logger

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    DynamicSupervisor.init(strategy: :one_for_one, extra_arguments: [args])
  end
  def add_updater(name) do
    try do
      String.to_existing_atom(name)
      spec = %{id: make_ref(), start: {ClientUpdater, :start_link, [name]}}
      DynamicSupervisor.start_child(__MODULE__, spec)
      {:ok, name}
    rescue
      e in ArgumentError -> {:error, e.message}
    end
  end
end
