defmodule Duper.Hasher.Gatherer do
  use GenServer

  alias Duper.Hasher.Worker

  def start_link(workers) do
    GenServer.start_link(__MODULE__, workers, name: __MODULE__)
  end

  def find_duplicates(root_path, timeout \\ :infinity) do
    GenServer.call(__MODULE__, {:find_duplicates, root_path}, timeout)
  end

  @impl GenServer
  def init(workers) do
    {:ok, workers}
  end

  @impl GenServer
  def handle_call({:find_duplicates, root_path}, _caller, workers) do
    IO.puts("Finding duplicates for: '#{root_path}'")

    hashes =
      root_path
      |> DirWalker.stream()
      |> Task.async_stream(Worker, :run, [],
        max_concurrency: workers,
        ordered: false,
        timeout: :infinity
      )
      |> Enum.group_by(&group_key/1, &group_value/1)

    {:reply, hashes, workers}
  end

  defp group_key({:ok, {_, hash}}), do: hash
  defp group_key({:error, _}), do: :error

  defp group_value({:ok, {path, _}}), do: path
  defp group_value({:error, exception}), do: exception
end
