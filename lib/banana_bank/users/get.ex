defmodule BananaBank.Users.Get do
  alias BananaBank.Users.User
  alias BananaBank.Repo

  def call(id) when is_binary(id) do
    case Integer.parse(id) do
      {int_id, _} -> call(int_id)
      :error -> {:error, "Invalid ID format"}
    end
  end

  def call(id) when is_integer(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

end
