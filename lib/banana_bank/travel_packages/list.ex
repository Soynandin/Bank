# lib/banana_bank/travel_packages/list.ex

defmodule BananaBank.TravelPackages.List do
  import Ecto.Query
  alias BananaBank.{Repo, TravelPackages.TravelPackage}

  def call(limit, offset, order_by, direction) do
    dir = String.to_atom(direction)
    field_atom = String.to_existing_atom(order_by)

    TravelPackage
    |> order_by([p], [{^dir, field(p, ^field_atom)}])
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  rescue
    _ -> Repo.all(TravelPackage)
  end
end
