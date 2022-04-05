defmodule Duper.Hasher.Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl GenServer
  def init(nil) do
    send(self(), :work)
    {:ok, nil}
  end

  @impl GenServer
  def handle_info(:work, nil) do
    case Duper.PathFinder.next() do
      nil ->
        IO.inspect(self(), label: "Worker done")
        Duper.Gatherer.done()
        {:stop, :normal, nil}

      path ->
        IO.inspect({self(), path}, label: "Worker hashing")
        Duper.Storage.add(path, hash(path))
        send(self(), :work)
        {:noreply, nil}
    end
  end

  defp hash(path) do
    File.stream!(path, [], 1024 * 1024)
    |> Enum.reduce(
      :crypto.hash_init(:md5),
      fn block, hash ->
        :crypto.hash_update(hash, block)
      end
    )
    |> :crypto.hash_final()
  end
end
