defmodule BananaBank.Users do
  alias BananaBank.Users.{Create, Get, Update, Delete, List, GetByEmail}

  # Delegação das funções para os respectivos módulos de serviço
  defdelegate get_all(limit, offset, order_by, direction), to: List, as: :call
  defdelegate get(id), to: Get, as: :call
  defdelegate get_by_email(email), to: GetByEmail, as: :call
  defdelegate create(params), to: Create, as: :call
  defdelegate update(params), to: Update, as: :call
  defdelegate delete(id), to: Delete, as: :call
end
