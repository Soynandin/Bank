defmodule BananaBank.Users.List do
  alias BananaBank.Users.User
  alias BananaBank.Repo
  import Ecto.Query, only: [from: 2]

  # Busca todos os usuários com paginação e ordenação
  def call(limit \\ 10, offset \\ 0, order_by \\ "name", direction \\ "asc") do
    # Converte a direção e o campo para símbolos
    order_direction = if direction == "asc", do: :asc, else: :desc
    order_field = String.to_atom(order_by)

    # Corrigindo a definição da consulta Ecto
    query = from u in User,
      order_by: [{^order_direction, field(u, ^order_field)}],  # Usando ^ corretamente dentro da consulta
      limit: ^limit,
      offset: ^offset

    Repo.all(query)
  end

  # Função para contar o número total de usuários
  def count_users do
    Repo.aggregate(User, :count, :id)
  end
end
