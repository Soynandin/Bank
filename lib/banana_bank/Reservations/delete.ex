# lib/banana_bank/reservations/delete.ex

defmodule BananaBank.Reservations.Delete do
  alias BananaBank.{Repo, Reservations.Reservation}

  def call(id) do
    case Repo.get(Reservation, id) do
      nil -> {:error, :not_found}
      reservation -> Repo.delete(reservation)
    end
  end
end
