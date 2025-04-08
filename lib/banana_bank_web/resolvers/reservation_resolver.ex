# lib/banana_bank_web/resolvers/reservation_resolver.ex

defmodule BananaBankWeb.Resolvers.ReservationResolver do
  alias BananaBank.Reservations

  def list_reservations(_, %{limit: limit, offset: offset, order_by: order_by, direction: direction}, _res) do
    {:ok, Reservations.get_all(limit, offset, order_by, direction)}
  end

  def get_reservation(_, %{id: id}, _res) do
    case Reservations.get(id) do
      nil -> {:error, "Reservation not found"}
      reservation -> {:ok, reservation}
    end
  end

  def create_reservation(_, %{input: input}, _res) do
    Reservations.create(input)
  end

  def update_reservation(_, %{input: input}, _res) do
    Reservations.update(input)
  end

  def delete_reservation(_, %{id: id}, _res) do
    Reservations.delete(id)
  end
end
