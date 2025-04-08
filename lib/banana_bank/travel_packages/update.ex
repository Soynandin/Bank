# lib/banana_bank/travel_packages/update.ex

defmodule BananaBank.TravelPackages.Update do
  alias BananaBank.{Repo, TravelPackages.TravelPackage}

  def call(%{id: id} = params) do
    with {:ok, package} <- BananaBank.TravelPackages.get(id) do
      package
      |> TravelPackage.changeset(params)
      |> Repo.update()
    end
  end
end
