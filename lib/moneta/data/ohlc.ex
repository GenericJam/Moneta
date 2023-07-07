defmodule Moneta.Data.Ohlc do
  use Ecto.Schema
  import Ecto.Changeset

  alias Ecto.Changeset

  schema "ohlcs" do
    field :close, :decimal
    field :high, :decimal
    field :low, :decimal
    field :open, :decimal
    field :timestamp, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(ohlc, attrs) do
    ohlc
    |> cast(attrs, [:open, :high, :low, :close, :timestamp])
    |> convert_values()
    |> validate_required([:open, :high, :low, :close, :timestamp])
  end

  defp convert_values(%Changeset{changes: changes} = changeset) do
    converted =
      changes
      |> Enum.reduce_while([], fn
        {:timestamp, timestamp}, acc ->
          {:cont, [{:timestamp, timestamp} | acc]}

        {key, value}, acc when key in [:open, :high, :low, :close] ->
          case Decimal.cast(value) do
            {:ok, decimal} ->
              {:cont, [{key, decimal} | acc]}

            _ ->
              {:halt, {:error, "Failed to parse float value"}}
          end
      end)

    case converted do
      {:error, _} -> add_error(changeset, :timestamp, "Failed to parse float value")
      _ -> %Changeset{changeset | changes: Map.new(converted)}
    end
  end
end
