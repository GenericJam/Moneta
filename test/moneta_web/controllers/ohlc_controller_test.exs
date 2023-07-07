defmodule MonetaWeb.OhlcControllerTest do
  use MonetaWeb.ConnCase

  @create_attrs %{
    close: 42.0,
    high: 42.0,
    low: 42.0,
    open: 42.0,
    timestamp: "2021-09-01T10:00:00Z"
  }

  @invalid_attrs %{close: nil, high: nil, low: nil, open: nil, timestamp: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create ohlc" do
    test "renders ohlc when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/insert", @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/ohlcs/#{id}")

      assert %{
               "id" => ^id,
               "close" => 42.0,
               "high" => 42.0,
               "low" => 42.0,
               "open" => 42.0,
               "timestamp" => "2021-09-01T10:00:00Z"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/insert", @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "moving average" do
    test "last 10 items", %{conn: conn} do
      now = Timex.now()

      for i <- 0..20 do
        create_attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, minutes: 0 - i)
        }

        post(conn, ~p"/api/insert", create_attrs)
      end

      conn = get(conn, ~p"/api/average/?window=last_10_items")

      assert %{"average" => 5.5} = json_response(conn, 200)["data"]
    end

    test "last 10 minutes", %{conn: conn} do
      now = Timex.now()

      for i <- 0..20 do
        create_attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, minutes: 0 - i, seconds: -2)
        }

        post(conn, ~p"/api/insert", create_attrs)
      end

      conn = get(conn, ~p"/api/average/?window=last_10_minutes")

      assert %{"average" => 5.5} = json_response(conn, 200)["data"]
    end

    test "last 10 hours", %{conn: conn} do
      now = Timex.now()

      for i <- 0..20 do
        create_attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, hours: 0 - i, seconds: -2)
        }

        post(conn, ~p"/api/insert", create_attrs)
      end

      conn = get(conn, ~p"/api/average/?window=last_10_hours")

      assert %{"average" => 5.5} = json_response(conn, 200)["data"]
    end

    test "last 10 days", %{conn: conn} do
      now = Timex.now()

      for i <- 0..20 do
        create_attrs = %{
          close: 1.0 + i,
          high: 42.0,
          low: 42.0,
          open: 42.0,
          timestamp: Timex.shift(now, days: 0 - i, seconds: -2)
        }

        post(conn, ~p"/api/insert", create_attrs)
      end

      conn = get(conn, ~p"/api/average/?window=last_10_days")

      assert %{"average" => 5.5} = json_response(conn, 200)["data"]
    end
  end
end
