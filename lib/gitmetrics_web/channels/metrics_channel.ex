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
  def handle_in(url, payload, socket) do
    metrics =
      url
      |> Managment.init_url
      |> Managment.api_call
      |> Managment.send_metrics
    broadcast! socket, "metrics", metrics
    {:noreply, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (metrics:lobby).

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
