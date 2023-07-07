defmodule Moneta.Data do
  @moduledoc """
  The Data context.
  """

  use Timex

  import Ecto.Query, warn: false
  alias Moneta.Repo

  alias Moneta.Data.Ohlc

  @doc """
  Returns the list of ohlcs.

  ## Examples

      iex> list_ohlcs()
      [%Ohlc{}, ...]

  """
  def list_ohlcs do
    Repo.all(Ohlc) |> Enum.map(fn record -> parse_decimal_per_record(record) end)
  end

  @doc """
  Gets a single ohlc.

  Raises `Ecto.NoResultsError` if the Ohlc does not exist.

  ## Examples

      iex> get_ohlc!(123)
      %Ohlc{}

      iex> get_ohlc!(456)
      ** (Ecto.NoResultsError)

  """
  def get_ohlc!(id), do: Repo.get!(Ohlc, id) |> parse_decimal_per_record()

  @doc """
  Creates a ohlc.

  ## Examples

      iex> create_ohlc(%{field: value})
      {:ok, %Ohlc{}}

      iex> create_ohlc(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_ohlc(attrs \\ %{}) do
    %Ohlc{}
    |> Ohlc.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a ohlc.

  ## Examples

      iex> update_ohlc(ohlc, %{field: new_value})
      {:ok, %Ohlc{}}

      iex> update_ohlc(ohlc, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_ohlc(%Ohlc{} = ohlc, attrs) do
    ohlc
    |> Ohlc.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ohlc.

  ## Examples

      iex> delete_ohlc(ohlc)
      {:ok, %Ohlc{}}

      iex> delete_ohlc(ohlc)
      {:error, %Ecto.Changeset{}}

  """
  def delete_ohlc(%Ohlc{} = ohlc) do
    Repo.delete(ohlc)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking ohlc changes.

  ## Examples

      iex> change_ohlc(ohlc)
      %Ecto.Changeset{data: %Ohlc{}}

  """
  def change_ohlc(%Ohlc{} = ohlc, attrs \\ %{}) do
    Ohlc.changeset(ohlc, attrs)
  end

  @doc """
  Takes a string like last_10_items or last_1_hour and returns the relevant moving average
  as %{average: 10.5}

  There is no rounding happening
  """
  def calc_window(window) do
    [_last, number, denomination] = String.split(window, "_")
    count = String.to_integer(number)

    now = Timex.now()

    sub =
      case denomination do
        d when d in ["item", "items"] ->
          from(Ohlc,
            limit: ^count
          )

        d when d in ["minute", "minutes"] ->
          then = Timex.shift(now, minutes: 0 - count)

          from(o in Ohlc,
            where: o.timestamp < ^now and o.timestamp > ^then
          )

        d when d in ["hour", "hours"] ->
          then = Timex.shift(now, hours: 0 - count)

          from(o in Ohlc,
            where: o.timestamp < ^now and o.timestamp > ^then
          )

        d when d in ["day", "days"] ->
          then = Timex.shift(now, days: 0 - count)

          from(o in Ohlc,
            where: o.timestamp < ^now and o.timestamp > ^then
          )

        _ ->
          []
      end

    average_as_list =
      from(o in subquery(sub),
        select: avg(o.close)
      )
      |> Repo.all()

    average =
      case average_as_list do
        [nil | _] -> nil
        [v | _] -> Decimal.to_float(v)
        _ -> nil
      end

    %{average: average}
  end

  # Convert Decimal back into float for a record
  defp parse_decimal_per_record(record) do
    parsed =
      record
      |> Map.from_struct()
      |> Enum.map(fn
        {key, value} when key in [:open, :high, :low, :close] ->
          float = Decimal.to_float(value)
          {key, float}

        {k, v} ->
          {k, v}
      end)
      |> Map.new()

    Map.merge(record, parsed)
  end
end
