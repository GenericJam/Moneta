defmodule MonetaWeb.OhlcController do
  use MonetaWeb, :controller

  alias Moneta.Data
  alias Moneta.Data.Ohlc

  action_fallback MonetaWeb.FallbackController

  def index(conn, %{"window" => window}) do
    ohlcs = Data.calc_window(window)
    render(conn, :index, ohlcs: ohlcs)
  end

  def index(conn, _params) do
    ohlcs = Data.list_ohlcs()
    render(conn, :index, ohlcs: ohlcs)
  end

  def create(conn, ohlc_params) when is_map(ohlc_params) do
    with {:ok, %Ohlc{} = ohlc} <- Data.create_ohlc(ohlc_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/ohlcs/#{ohlc.id}")
      |> render(:show, ohlc: ohlc)
    end
  end

  def show(conn, %{"id" => id}) do
    ohlc = Data.get_ohlc!(id)
    render(conn, :show, ohlc: ohlc)
  end

  def update(conn, %{"id" => id, "ohlc" => ohlc_params}) do
    ohlc = Data.get_ohlc!(id)

    with {:ok, %Ohlc{} = ohlc} <- Data.update_ohlc(ohlc, ohlc_params) do
      render(conn, :show, ohlc: ohlc)
    end
  end

  def delete(conn, %{"id" => id}) do
    ohlc = Data.get_ohlc!(id)

    with {:ok, %Ohlc{}} <- Data.delete_ohlc(ohlc) do
      send_resp(conn, :no_content, "")
    end
  end
end
