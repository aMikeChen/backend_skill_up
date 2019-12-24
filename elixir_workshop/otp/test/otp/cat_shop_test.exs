defmodule Otp.CatShopTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import ExUnit.CaptureIO

  alias Otp.{Cat, CatShop}

  defp cat_generator do
    map(
      {string(:printable), string(:printable), string(:printable)},
      fn {name, color, description} ->
        %Cat{name: name, color: color, description: description}
      end
    )
  end

  describe "start_link/1" do
    test "returns alive cat shop pid" do
      assert {:ok, pid} = CatShop.start_link([])
      assert Process.alive?(pid) == true
    end
  end

  describe "order_cat/4" do
    property "when no cat in the shop" do
      {:ok, pid} = CatShop.start_link([])

      check all(cat <- cat_generator(), max_runs: 10) do
        assert CatShop.order_cat(pid, cat.name, cat.color, cat.description) == cat
      end
    end

    property "when some cats in the shop" do
      check all([cat | _] = cats <- list_of(cat_generator()), max_runs: 10) do
        {:ok, pid} = CatShop.start_link(cats)
        assert CatShop.order_cat(pid, "kitty", "white", "white kitty") == cat
      end
    end
  end

  describe "return_cat/2" do
    property "returns cat to shop" do
      check all(cat <- cat_generator(), max_runs: 10) do
        assert CatShop.return_cat(self(), cat) == :ok
        assert_received {:"$gen_cast", {:return, cat}}
      end
    end
  end

  describe "close_shop/1" do
    test "terminate cat shop process" do
      {:ok, pid} = CatShop.start_link()
      assert CatShop.close_shop(pid) == :ok
      assert Process.alive?(pid) == false
    end
  end

  describe "init/1" do
    property "returns initial cats" do
      check all(cats <- list_of(cat_generator()), max_runs: 10) do
        assert CatShop.init(cats) == {:ok, cats}
      end
    end
  end

  describe "handle_call :order" do
    property "when some cats in state" do
      check all([cat | rest_cats] = cats <- list_of(cat_generator()), max_runs: 10) do
        assert CatShop.handle_call({:order, "kitty", "white", "white kitty"}, self(), cats) ==
                 {:reply, cat, rest_cats}
      end
    end

    property "when state is empty" do
      check all(cat <- cat_generator(), max_runs: 10) do
        assert CatShop.handle_call({:order, cat.name, cat.color, cat.description}, self(), []) ==
                 {:reply, cat, []}
      end
    end
  end

  describe "handle_call :return" do
    property "add cat into state" do
      check all(cat <- cat_generator(), cats <- list_of(cat_generator()), max_runs: 10) do
        assert CatShop.handle_cast({:return, cat}, cats) == {:noreply, [cat | cats]}
      end
    end
  end

  describe "terminate" do
    property "print free cats message" do
      check all(cats <- list_of(cat_generator()), max_runs: 10) do
        fun = fn ->
          assert CatShop.terminate(:normal, cats) == :ok
        end

        expected = cats |> Enum.map(&"#{&1.name} was set free.\n") |> Enum.join()
        assert capture_io(fun) == expected
      end
    end
  end
end
