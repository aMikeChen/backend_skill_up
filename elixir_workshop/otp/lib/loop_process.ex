defmodule LoopProcess do
  def loop() do
    receive do
      :stop ->
        :stop

      message ->
        IO.inspect("#{inspect(self())} receive: #{message}")
        loop()
    end
  end
end
