defmodule BananaBank.Repo.Migrations.CreateTravelPackagesTable do
  use Ecto.Migration

  def change do
    create table(:travel_packages) do
      add :title, :string, null: false
      add :destination, :string, null: false
      add :price, :decimal, null: false
      add :availability_start_date, :date, null: false
      add :availability_end_date, :date, null: false
      add :description, :text
      add :cancellation_policy, :string, null: false
      add :total_slots, :integer, null: false
      add :remaining_slots, :integer, null: false
      add :status, :string, null: false

      # FK para a agência — assumindo que sua tabela de usuários usa bigint como id
      add :agency_id, references(:users, type: :bigint, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:travel_packages, [:agency_id])
  end
end
