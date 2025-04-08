defmodule BananaBank.Reservations.List do
  # Importa funções para construção de queries com Ecto
  import Ecto.Query

  # Define o alias para facilitar acesso ao repositório e schema
  alias BananaBank.{Repo, Reservations.Reservation}

  # Lista de direções permitidas para ordenação
  @allowed_directions [:asc, :desc]

  # Lista de campos permitidos para ordenação
  @allowed_fields [:id, :status, :reservation_date, :expiration_date, :total_price, :traveler_count]

  # Função principal que recebe os parâmetros de paginação e ordenação
  def call(limit, offset, order_by, direction) do
    # Converte os parâmetros order_by e direction para átomos seguros
    order_field = safe_to_atom(order_by, @allowed_fields, :id)
    direction_atom = safe_to_atom(direction, @allowed_directions, :asc)

    # Cria uma query base carregando relações (associações) de client, package e agency
    base_query =
      from r in Reservation,
        preload: [:client, :package, :agency]

    # Adiciona ordenação à query com base na direção escolhida
    ordered_query =
      case direction_atom do
        :asc -> from r in base_query, order_by: [asc: field(r, ^order_field)]
        :desc -> from r in base_query, order_by: [desc: field(r, ^order_field)]
      end

    # Aplica paginação (limit e offset) e executa a query no banco de dados
    ordered_query
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  # Função auxiliar para converter string em átomo seguro
  defp safe_to_atom(string, allowed, default) do
    try do
      # Converte string em átomo existente
      atom = String.to_existing_atom(string)

      # Verifica se o átomo convertido está entre os valores permitidos
      if atom in allowed, do: atom, else: default
    rescue
      # Se a conversão falhar (ex: átomo não existe), retorna valor padrão
      _ -> default
    end
  end
end
