defmodule MonetaWeb.OhlcJSON do
  alias Moneta.Data.Ohlc

  @doc """
  Renders a list of ohlcs.
  """
  def index(%{ohlcs: ohlcs}) when is_list(ohlcs) do
    %{data: for(ohlc <- ohlcs, do: data(ohlc))}
  end

  def index(%{ohlcs: ohlcs}) when is_map(ohlcs) do
    %{data: ohlcs}
  end

  @doc """
  Renders a single ohlc.
  """
  def show(%{ohlc: ohlc}) do
    %{data: data(ohlc)}
  end

  defp data(%Ohlc{} = ohlc) do
    %{
      id: ohlc.id,
      open: ohlc.open,
      high: ohlc.high,
      low: ohlc.low,
      close: ohlc.close,
      timestamp: ohlc.timestamp
    }
  end

  defp data(avg_close) do
    avg_close
  end
end
