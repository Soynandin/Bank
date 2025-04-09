defmodule BananaBank.Repo.Migrations.CreateReservations do
  use Ecto.Migration

  def change do
    create table(:reservations) do
      add :client_id, references(:users, on_delete: :nilify_all)
      add :package_id, references(:travel_packages, on_delete: :nilify_all)
      add :agency_id, references(:users, on_delete: :nilify_all)

      add :status, :string, null: false
      add :token, :uuid, null: false
      add :reservation_date, :utc_datetime, null: false
      add :expiration_date, :utc_datetime, null: false
      add :payment_method, :string
      add :total_price, :decimal
      add :traveler_count, :integer
      add :cancellation_policy, :string

      timestamps()
    end

    create index(:reservations, [:client_id])
    create index(:reservations, [:package_id])
    create index(:reservations, [:agency_id])
    create unique_index(:reservations, [:token])
  end
end
