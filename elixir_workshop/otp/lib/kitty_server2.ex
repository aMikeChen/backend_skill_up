defmodule KittyServer2 do
  defmodule Cat do
    defstruct name: nil, color: :black, description: nil
  end

  # ------------------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------------------

  def start_link() do
    MyServer.start_link(__MODULE__, [])
  end

  # Synchronous call
  def order_cat(pid, name, color, description) do
    MyServer.call(pid, {:order, name, color, description})
  end

  # Asynchronous call
  def return_cat(pid, %Cat{} = cat) do
    MyServer.cast(pid, {:return, cat})
  end

  # Synchronous call
  def close_shop(pid) do
    MyServer.call(pid, :terminate)
  end

  # ------------------------------------------------------------------------------
  # Server functions
  # ------------------------------------------------------------------------------

  def init([]) do
    []
  end

  def handle_call({:order, name, color, description}, from, cats) do
    case cats do
      [] ->
        cat = make_cat(name, color, description)
        MyServer.reply(from, cat)
        cats

      [cat | tail] ->
        MyServer.reply(from, cat)
        tail
    end
  end

  def handle_call(:terminate, from, cats) do
    MyServer.reply(from, :ok)
    terminate(cats)
  end

  def handle_cast({:return, cat}, cats) do
    [cat | cats]
  end

  defp make_cat(name, color, description) do
    %Cat{name: name, color: color, description: description}
  end

  defp terminate(cats) do
    for cat <- cats, do: IO.inspect("#{cat.name} was set free.")
    exit(:normal)
  end
end
