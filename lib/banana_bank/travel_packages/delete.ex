defmodule BananaBank.TravelPackages.Delete do
  alias BananaBank.Repo

  def call(id) do
    with {:ok, package} <- BananaBank.TravelPackages.get(id) do
      Repo.delete(package)
    end
  end
end
