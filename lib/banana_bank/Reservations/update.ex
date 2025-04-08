# lib/banana_bank/reservations/update.ex

defmodule BananaBank.Reservations.Update do
  alias BananaBank.{Repo, Reservations.Reservation}

  def call(%{"id" => id} = params) do
    case Repo.get(Reservation, id) do
      nil -> {:error, :not_found}
      reservation ->
        reservation
        |> Reservation.changeset(params)
        |> Repo.update()
    end
  end
end
