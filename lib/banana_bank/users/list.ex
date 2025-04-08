defmodule BananaBank.Users.List do
  alias BananaBank.Users.User
  alias BananaBank.Repo
  import Ecto.Query, only: [from: 2]

  @valid_fields ~w(first_name last_name email document role)a

  def call(limit \\ 10, offset \\ 0, order_by \\ "first_name", direction \\ "asc") do
    order_direction = if direction == "asc", do: :asc, else: :desc

    # Validação do campo de ordenação
    order_field =
      if order_by in @valid_fields do
        String.to_atom(order_by)
      else
        :first_name
      end

    query =
      from u in User,
        order_by: [{^order_direction, field(u, ^order_field)}],
        limit: ^limit,
        offset: ^offset

    Repo.all(query)
  end

  def count_users do
    Repo.aggregate(User, :count, :id)
  end
end
