defmodule BananaBank.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :client_id, references(:users)
      add :package_id, references(:travel_packages)
      add :agency_id, references(:users)

      add :status, :string
      add :reservation_date, :utc_datetime
      add :expiration_date, :utc_datetime
      add :payment_method, :string
      add :total_price, :decimal
      add :traveler_count, :integer
      add :cancellation_policy, :string

      timestamps()
    end

    create index(:reservations, [:client_id])
    create index(:reservations, [:package_id])
    create index(:reservations, [:agency_id])
  end
end
