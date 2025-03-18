defmodule BananaBank.Users do
  alias BananaBank.Users.{Create, Get, Update, Delete, List, GetByEmail}

  # Delegação das funções para os respectivos módulos de serviço
  defdelegate create(params), to: Create, as: :call   # Encaminha create para Create.call/1
  defdelegate get(id), to: Get, as: :call             # Encaminha get para Get.call/1
  defdelegate update(params), to: Update, as: :call   # Encaminha update para Update.call/1
  defdelegate delete(id), to: Delete, as: :call       # Encaminha delete para Delete.call/1
  defdelegate get_all(limit, offset, order_by, direction), to: List, as: :call
  defdelegate get_by_email(email), to: GetByEmail, as: :call
end
