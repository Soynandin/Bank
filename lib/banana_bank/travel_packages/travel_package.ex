defmodule BananaBank.TravelPackages.TravelPackage do
  use Ecto.Schema
  import Ecto.Changeset

  @cancellation_policies ~w(flexivel moderada rigida)a
  @status_options ~w(ativo desativado pendente)a

  @derive {Jason.Encoder, only: [
    :id, :title, :destination, :price, :availability_start_date, :availability_end_date,
    :description, :cancellation_policy, :total_slots, :remaining_slots,
    :status, :agency_id
  ]}

  schema "travel_packages" do
    field :title, :string
    field :destination, :string
    field :price, :decimal
    field :availability_start_date, :date
    field :availability_end_date, :date
    field :description, :string
    field :cancellation_policy, Ecto.Enum, values: @cancellation_policies
    field :total_slots, :integer
    field :remaining_slots, :integer
    field :status, Ecto.Enum, values: @status_options
    field :agency_id, :id

    belongs_to :agency, BananaBank.Users.User, define_field: false

    timestamps()
  end

  def changeset(package, attrs) do
    package
    |> cast(attrs, __MODULE__.__schema__(:fields) -- [:id, :inserted_at, :updated_at])
    |> validate_required([:title, :destination, :price, :availability_start_date, :availability_end_date, :cancellation_policy, :total_slots, :remaining_slots, :status, :agency_id])
    |> validate_inclusion(:cancellation_policy, @cancellation_policies)
    |> validate_inclusion(:status, @status_options)
  end
end
