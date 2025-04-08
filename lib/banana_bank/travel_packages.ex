# lib/banana_bank/travel_packages.ex
defmodule BananaBank.TravelPackages do
  alias BananaBank.TravelPackages.{Create, Get, Update, Delete, List}

  defdelegate create(params), to: Create, as: :call
  defdelegate get(id), to: Get, as: :call
  defdelegate update(params), to: Update, as: :call
  defdelegate delete(id), to: Delete, as: :call
  defdelegate list_all(limit, offset, order_by, direction), to: List, as: :call
end
