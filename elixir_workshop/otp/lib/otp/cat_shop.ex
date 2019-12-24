defmodule Otp.CatShop do
  use GenServer

  alias Otp.Cat

  def start_link(initial_cats \\ []) do
    GenServer.start_link(__MODULE__, initial_cats)
  end

  def order_cat(pid, name, color, description) do
    GenServer.call(pid, {:order, name, color, description})
  end

  def return_cat(pid, %Cat{} = cat) do
    GenServer.cast(pid, {:return, cat})
  end

  def close_shop(pid) do
    GenServer.stop(pid)
  end

  @impl true
  def init(initial_cats) do
    {:ok, initial_cats}
  end

  @impl true
  def handle_call({:order, _, _, _}, _from, [cat | rest_cats]) do
    {:reply, cat, rest_cats}
  end

  @impl true
  def handle_call({:order, name, color, description}, _from, cats) do
    cat = %Cat{name: name, color: color, description: description}
    {:reply, cat, cats}
  end

  @impl true
  def handle_cast({:return, cat}, cats) do
    {:noreply, [cat | cats]}
  end

  @impl true
  def terminate(_, cats) do
    for cat <- cats, do: IO.puts("#{cat.name} was set free.")
    :ok
  end
end
