defmodule Moneta.DataFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Moneta.Data` context.
  """

  @doc """
  Generate a ohlc.
  """
  def ohlc_fixture(attrs \\ %{}) do
    {:ok, ohlc} =
      attrs
      |> Enum.into(%{
        close: 42.0,
        high: 42.0,
        low: 42.0,
        open: 42.0,
        timestamp: "2021-09-01T11:00:00Z"
      })
      |> Moneta.Data.create_ohlc()

    Moneta.Data.get_ohlc!(ohlc.id)
  end
end
