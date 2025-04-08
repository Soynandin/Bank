defmodule BananaBank.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset

  alias BananaBank.Users.User
  alias BananaBank.TravelPackages.TravelPackage

  @status [:pending, :confirmed, :expired, :canceled, :refunded]
  @payment_methods [:pix, :credit_card, :boleto]
  @cancellation_policies [:flexivel, :moderada, :rigida]

  schema "reservations" do
    belongs_to :client, User
    belongs_to :package, TravelPackage
    belongs_to :agency, User

    field :status, Ecto.Enum, values: @status
    field :reservation_date, :utc_datetime
    field :expiration_date, :utc_datetime
    field :payment_method, Ecto.Enum, values: @payment_methods
    field :total_price, :decimal
    field :traveler_count, :integer
    field :cancellation_policy, Ecto.Enum, values: @cancellation_policies

    timestamps()
  end

  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [
      :client_id,
      :package_id,
      :agency_id,
      :status,
      :reservation_date,
      :expiration_date,
      :payment_method,
      :total_price,
      :traveler_count,
      :cancellation_policy
    ])
    |> validate_required([
      :client_id,
      :package_id,
      :agency_id,
      :status,
      :reservation_date,
      :expiration_date,
      :total_price,
      :traveler_count,
      :cancellation_policy
    ])
    |> foreign_key_constraint(:client_id)
    |> foreign_key_constraint(:package_id)
    |> foreign_key_constraint(:agency_id)
  end
end
