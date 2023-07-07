defmodule Moneta.Repo.Migrations.CreateOhlcs do
  use Ecto.Migration

  def change do
    create table(:ohlcs) do
      add :open, :decimal
      add :high, :decimal
      add :low, :decimal
      add :close, :decimal
      add :timestamp, :utc_datetime

      timestamps()
    end
  end
end
