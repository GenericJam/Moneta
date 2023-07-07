defmodule Moneta.DataTest do
  use Moneta.DataCase

  alias Moneta.Data

  describe "ohlcs" do
    alias Moneta.Data.Ohlc

    import Moneta.DataFixtures

    @invalid_attrs %{close: nil, high: nil, low: nil, open: nil}

    test "list_ohlcs/0 returns all ohlcs" do
      ohlc = ohlc_fixture()
      assert Data.list_ohlcs() == [ohlc]
    end

    test "get_ohlc!/1 returns the ohlc with given id" do
      ohlc = ohlc_fixture()
      assert Data.get_ohlc!(ohlc.id) == ohlc
    end

    test "create_ohlc/1 with valid data creates a ohlc" do
      valid_attrs = %{close: 42, high: 42, low: 42, open: 42, timestamp: "2021-09-01T11:00:00Z"}

      assert {:ok, %Ohlc{} = ohlc} = Data.create_ohlc(valid_attrs)
      ohlc = Data.get_ohlc!(ohlc.id)
      assert ohlc.close == 42
      assert ohlc.high == 42
      assert ohlc.low == 42
      assert ohlc.open == 42
    end

    test "create_ohlc/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Data.create_ohlc(@invalid_attrs)
    end

    test "update_ohlc/2 with valid data updates the ohlc" do
      ohlc = ohlc_fixture()
      update_attrs = %{close: 43, high: 43, low: 43, open: 43}

      assert {:ok, %Ohlc{} = ohlc} = Data.update_ohlc(ohlc, update_attrs)
      ohlc = Data.get_ohlc!(ohlc.id)
      assert ohlc.close == 43
      assert ohlc.high == 43
      assert ohlc.low == 43
      assert ohlc.open == 43
    end

    test "update_ohlc/2 with invalid data returns error changeset" do
      ohlc = ohlc_fixture()
      assert {:error, %Ecto.Changeset{}} = Data.update_ohlc(ohlc, @invalid_attrs)
      assert ohlc == Data.get_ohlc!(ohlc.id)
    end

    test "delete_ohlc/1 deletes the ohlc" do
      ohlc = ohlc_fixture()
      assert {:ok, %Ohlc{}} = Data.delete_ohlc(ohlc)
      assert_raise Ecto.NoResultsError, fn -> Data.get_ohlc!(ohlc.id) end
    end

    test "change_ohlc/1 returns a ohlc changeset" do
      ohlc = ohlc_fixture()
      assert %Ecto.Changeset{} = Data.change_ohlc(ohlc)
    end

    test "calc_window/1 returns an average of last 10 items" do
      now = Timex.now()

      for i <- 0..20 do
        attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, days: 0 - i)
        }

        Data.create_ohlc(attrs)
      end

      assert %{average: 5.5} == Data.calc_window("last_10_items")
    end

    test "calc_window/1 returns an average of last 1 hour" do
      now = Timex.now()

      for i <- 0..80 do
        attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, minutes: 0 - i, seconds: -2)
        }

        Data.create_ohlc(attrs)
      end

      assert %{average: 30.5} == Data.calc_window("last_1_hour")
    end

    test "calc_window/1 returns an average of last 10 hours" do
      now = Timex.now()

      for i <- 0..800 do
        attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, minutes: 0 - i, seconds: -2)
        }

        Data.create_ohlc(attrs)
      end

      assert %{average: 300.5} == Data.calc_window("last_10_hours")
    end

    test "calc_window/1 returns an average of last 10 days" do
      now = Timex.now()

      for i <- 0..15000 do
        attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, minutes: 0 - i, seconds: -2)
        }

        Data.create_ohlc(attrs)
      end

      assert %{average: 7200.5} == Data.calc_window("last_10_days")
    end
  end
end
