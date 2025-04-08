# lib/banana_bank/travel_packages/get.ex

defmodule BananaBank.TravelPackages.Get do
  alias BananaBank.{Repo, TravelPackages.TravelPackage}

  def call(id) do
    case Repo.get(TravelPackage, id) do
      nil -> {:error, :not_found}
      package -> {:ok, package}
    end
  end
end
