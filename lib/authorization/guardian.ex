defmodule Gitmetrics.Guardian do
  use Guardian, otp_app: :gitmetrics

  def subject_for_token(resource, _claims) do
    {:ok, resource}
  end

  def resource_from_claims(claims) do
    {:ok, claims["sub"]}
  end
end
