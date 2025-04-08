# lib/banana_bank_web/resolvers/travel_package_resolver.ex
defmodule BananaBankWeb.Resolvers.TravelPackageResolver do
  alias BananaBank.TravelPackages

  def list_packages(_parent, args, _res) do
    {:ok, TravelPackages.list_all(args.limit || 10, args.offset || 0, args.order_by || "title", args.direction || "asc")}
  end

  def get_package(_, %{id: id}, _) do
    case TravelPackages.get(id) do
      {:ok, pkg} -> {:ok, pkg}
      {:error, _} -> {:error, "Package not found"}
    end
  end

  def create_package(_, args, %{context: %{current_user: %{role: "agency", id: agency_id}}}) do
    args = Map.put(args, :agency_id, agency_id)

    case TravelPackages.create(args) do
      {:ok, pkg} -> {:ok, pkg}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def update_package(_, args, _res) do
    case TravelPackages.update(args) do
      {:ok, pkg} -> {:ok, pkg}
      {:error, reason} -> {:error, reason}
    end
  end

  def delete_package(_, %{id: id}, _) do
    case TravelPackages.delete(id) do
      {:ok, _} -> {:ok, %{message: "Deleted"}}
      {:error, _} -> {:error, %{message: "Failed"}}
    end
  end
end
