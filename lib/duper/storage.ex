defmodule Duper.Storage do
  use GenServer

  @typep hash :: String.t()
  @typep path :: String.t()
  @typep state :: %{hash() => [path()]}

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @spec add(path(), hash()) :: :ok
  def add(filename, hash) do
    GenServer.cast(__MODULE__, {:add_hash, filename, hash})
  end

  @spec duplicates() :: [String.t()]
  def duplicates() do
    GenServer.call(__MODULE__, {:find_duplicates})
  end

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_cast({:add_hash, filename, hash}, state) do
    {:noreply, Map.update(state, hash, [filename], &[filename | &1])}
  end

  def handle_cast(msg, state) do
    log_unhandled_message(:no_handle_cast, msg)
    {:noreply, state}
  end

  @impl GenServer
  def handle_call({:find_duplicates}, _caller, state) do
    duplicates =
      state
      |> Enum.filter(fn {_key, list} -> length(list) > 1 end)
      |> Enum.into(%{})

    {:reply, duplicates, state}
  end

  def handle_call(msg, _caller, state) do
    log_unhandled_message(:no_handle_call, msg)
    {:reply, nil, state}
  end

  defp log_unhandled_message(label, msg) do
    :logger.error(%{
      label: {__MODULE__, label},
      report: %{
        module: __MODULE__,
        message: msg
      }
    })
  end
end
