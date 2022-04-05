defmodule Duper.Gatherer do
  use GenServer

  import Duper.Hasher.Supervisor, only: [add_worker: 0]

  @spec start_link(pos_integer()) :: GenServer.on_start()
  def start_link(workers) do
    GenServer.start_link(__MODULE__, workers, name: __MODULE__)
  end

  @spec done() :: :ok
  def done() do
    GenServer.cast(__MODULE__, :done)
  end

  @impl GenServer
  def init(workers) do
    send(self(), :initialize)
    {:ok, workers}
  end

  @impl GenServer
  def handle_info(:initialize, workers) do
    1..workers
    |> Enum.each(fn _ -> add_worker() end)

    {:noreply, workers}
  end

  @impl GenServer
  def handle_cast(:done, 1) do
    IO.inspect(Duper.Storage.duplicates(), label: "Results")
    System.halt()
  end

  def handle_cast(:done, workers) do
    {:noreply, workers - 1}
  end
end
