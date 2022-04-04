defmodule Duper.PathFinder do
  use GenServer

  def start_link(root) do
    GenServer.start_link(__MODULE__, root, name: __MODULE__)
  end

  def next() do
    GenServer.call(__MODULE__, :next)
  end

  @impl GenServer
  def init(root) do
    DirWalker.start_link(root)
  end

  @impl GenServer
  def handle_call(:next, _caller, state) do
    path =
      case DirWalker.next(state) do
        [path] -> path
        other -> other
      end

    {:reply, path, state}
  end
end
