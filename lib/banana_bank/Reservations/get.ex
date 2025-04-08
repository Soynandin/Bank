# lib/banana_bank/reservations/get.ex

defmodule BananaBank.Reservations.Get do
  alias BananaBank.{Repo, Reservations.Reservation}

  def call(id), do: Repo.get(Reservation, id) |> Repo.preload([:client, :package, :agency])
end
