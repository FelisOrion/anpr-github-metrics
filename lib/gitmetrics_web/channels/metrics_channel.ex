defmodule GitmetricsWeb.MetricsChannel do
  use GitmetricsWeb, :channel

  alias Gitmetrics.Managment

  def join("metrics:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("stato", _payload, socket) do
    metrics =
      {"era", "pay"}
      # payload.url
      # |> Managment.init_url
      |> Managment.api_call
      |> Managment.send_metrics_stato
    push socket, "stato", metrics
    {:noreply, socket}
  end

  def handle_in("resptimed", _payload, socket) do
    metrics =
      {"era", "pay"}
      # payload.url
      # |> Managment.init_url
      |> Managment.api_call()
      |> Managment.send_issues_time("era", "pay", Tentacat.Client.new(%{user: "FelisOrion", password: "salaculo21122012"}))
    push socket, "resptimed", %{list: metrics}
    {:noreply, socket}
  end

  def handle_in("lista", _payload, socket) do
    metrics =
      {"era", "pay"}
      # payload.url
      # |> Managment.init_url
      |> Managment.api_call
      |> Managment.send_metrics_lista
    push socket, "lista", metrics
    {:noreply, socket}
  end
  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (metrics:lobby).

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
