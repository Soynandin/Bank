# lib/banana_bank_web/resolvers/reservation_resolver.ex

defmodule BananaBankWeb.Resolvers.ReservationResolver do
  alias BananaBank.Reservations

  def list_reservations(_, %{limit: limit, offset: offset, order_by: order_by, direction: direction}, _res) do
    {:ok, Reservations.get_all(limit, offset, order_by, direction)}
  end

  def get_reservation(_, %{id: id}, %{context: %{current_user: %{id: user_id, role: "client"}}}) do
    case Reservations.get(id) do
      nil -> {:error, "Reservation not found"}
      %{client_id: ^user_id} = reservation -> {:ok, reservation}
      _ -> {:error, "Unauthorized"}
    end
  end

  # Admins ou Agências podem ver tudo (exemplo)
  def get_reservation(_, %{id: id}, %{context: %{current_user: %{role: role}}}) when role in ["admin", "agency"] do
    case Reservations.get(id) do
      nil -> {:error, "Reservation not found"}
      reservation -> {:ok, reservation}
    end
  end


  def create_reservation(_, %{input: input}, _res) do
    Reservations.create(input)
  end

  def create_temporary_reservation(_, %{client_id: client_id, package_id: package_id}, _) do
    case Reservations.create_temporary_reservation(client_id, package_id) do
      {:ok, reservation} -> {:ok, reservation}
      {:error, changeset} -> {:error, format_changeset_errors(changeset)}
    end
  end

  defp format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def update_reservation(_, %{input: input}, _res) do
    Reservations.update(input)
  end

  def delete_reservation(_, %{id: id}, _res) do
    Reservations.delete(id)
  end

end
