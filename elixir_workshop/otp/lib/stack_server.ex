defmodule StackServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call(:pop, _from, [item | state]) do
    {:reply, item, state}
  end

  def handle_cast({:push, item}, state) do
    {:noreply, [item | state]}
  end

  def handle_info(:print, state) do
    IO.inspect("State of server is #{inspect(state)}")
    {:noreply, state}
  end
end
