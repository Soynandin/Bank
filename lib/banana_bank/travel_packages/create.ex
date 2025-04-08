# lib/banana_bank/travel_packages/create.ex

defmodule BananaBank.TravelPackages.Create do
  alias BananaBank.{Repo, TravelPackages.TravelPackage}

  def call(params) do
    %TravelPackage{}
    |> TravelPackage.changeset(params)
    |> Repo.insert()
  end
end
