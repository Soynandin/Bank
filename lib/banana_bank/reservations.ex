defmodule BananaBank.Reservations do
  alias BananaBank.Reservations.{Create, Get, Update, Delete, List}

  defdelegate get_all(limit, offset, order_by, direction), to: List, as: :call
  defdelegate get(id), to: Get, as: :call
  defdelegate create(params), to: Create, as: :call
  defdelegate create_temporary_reservation(client_id, package_id), to: Create
  defdelegate update(params), to: Update, as: :call
  defdelegate delete(id), to: Delete, as: :call
end
