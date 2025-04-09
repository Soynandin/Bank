# lib/banana_bank/reservations/reservation.ex
defmodule BananaBank.Reservations.Reservation do
  use Ecto.Schema
  import Ecto.Changeset
  alias BananaBank.Users.User
  alias BananaBank.TravelPackages.TravelPackage

  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :id
  schema "reservations" do
    belongs_to :client, User
    belongs_to :package, TravelPackage
    belongs_to :agency, User

    field :status, :string
    field :token, Ecto.UUID
    field :reservation_date, :utc_datetime
    field :expiration_date, :utc_datetime
    field :payment_method, :string
    field :total_price, :decimal
    field :traveler_count, :integer
    field :cancellation_policy, :string

    timestamps()
  end

  def changeset(reservation, attrs) do
    reservation
    |> cast(attrs, [
      :client_id,
      :package_id,
      :agency_id,
      :status,
      :token,
      :reservation_date,
      :expiration_date,
      :payment_method,
      :total_price,
      :traveler_count,
      :cancellation_policy
    ])
    |> validate_required([:client_id, :package_id, :agency_id, :status, :token, :reservation_date, :expiration_date])
    |> unique_constraint(:token)
  end
end
