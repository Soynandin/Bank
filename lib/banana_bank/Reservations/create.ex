# lib/banana_bank/reservations/create.ex

defmodule BananaBank.Reservations.Create do
  alias BananaBank.{Repo, Reservations.Reservation}

  def call(params) do
    %Reservation{}
    |> Reservation.changeset(params)
    |> Repo.insert()
  end
end
