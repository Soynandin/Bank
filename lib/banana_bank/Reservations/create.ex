defmodule BananaBank.Reservations.Create do
  alias BananaBank.Repo
  alias BananaBank.Reservations.Reservation
  alias BananaBank.TravelPackages.TravelPackage

  # Criação genérica de reserva
  def call(params) do
    %Reservation{}
    |> Reservation.changeset(params)
    |> Repo.insert()
  end

  # Criação de reserva temporária com token e expiração
  def create_temporary_reservation(client_id, package_id) do
    with {:ok, package} <- get_package(package_id),
         token <- Ecto.UUID.generate(),
         now <- DateTime.utc_now(),
         expiration <- DateTime.add(now, 86_400, :second),
         attrs <- %{
          client_id: client_id,
          package_id: package_id,
          agency_id: package.agency_id,
          status: "pending",
          token: token,
          reservation_date: now,
          expiration_date: expiration,
          payment_method: nil,
          total_price: package.price,
          traveler_count: 1,
          cancellation_policy: Atom.to_string(package.cancellation_policy)
        } do
      %Reservation{}
      |> Reservation.changeset(attrs)
      |> Repo.insert()
    else
      error -> error
    end
  end

  # Busca segura do pacote de viagem
  defp get_package(id) when is_integer(id) do
    case Repo.get(TravelPackage, id) do
      nil -> {:error, :package_not_found}
      package -> {:ok, package}
    end
  end
end
