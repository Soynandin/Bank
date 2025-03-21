defmodule BananaBank.Guardian do
  use Guardian, otp_app: :banana_bank

  alias BananaBank.Users

  @impl true
  def subject_for_token(user, _claims), do: {:ok, to_string(user.id)}

  @impl true
  def resource_from_claims(%{"sub" => id}) do
    case Users.Get.call(id) do   # Corrigido de Users.get(id) para Users.Get.call(id)
      {:ok, user} -> {:ok, user}
      {:error, _} -> {:error, :not_found}
    end
  end
end
