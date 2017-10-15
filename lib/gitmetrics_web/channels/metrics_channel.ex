defmodule GitmetricsWeb.MetricsChannel do
  use GitmetricsWeb, :channel

  alias Gitmetrics.Managment
  alias Gitmetrics.Guardian

  def join("metrics:lobby", payload, socket) do
    if auth?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("stato", payload, socket) do
    metrics =
      payload["url"]
      |> Managment.init_url
      |> authorized?(payload)
      |> Managment.send_metrics_stato
    push socket, "stato", metrics
    {:noreply, socket}
  end

#%{user: payload["user"], password: payload["password"]}
  def handle_in("resptime", payload, socket) do
    with  {org, repo} <- Managment.init_url(payload["url"]),
          {:ok, metrics} <- Cachex.get(:cache, "#{org}/#{repo}/resptime") do
          push socket, "resptime", %{resp: metrics}
    else
      _ -> metrics =
              payload["url"]
              |> Managment.init_url
              |> authorized?(payload)
              |> send_issues_time_auth?(payload)
            push socket, "resptime", %{resp: metrics}
    end
    {:noreply, socket}
  end

  def handle_in("info", payload, socket) do
    metrics =
      payload["url"]
      |> Managment.init_url
      |> authorized?(payload)
      |> Managment.send_info_status()
    push socket, "info", metrics
    {:noreply, socket}
  end

  def handle_in("closetime", payload, socket) do
    metrics =
      payload["url"]
      |> Managment.init_url()
      |> authorized?(payload)
      |> Managment.send_close_time()
    push socket, "closetime", %{close: metrics}
    {:noreply, socket}
  end

  def handle_in("lista", payload, socket) do
    metrics =
      payload["url"]
      |> Managment.init_url()
      |> authorized?(payload)
      |> Managment.send_metrics_lista
    push socket, "lista", metrics
    {:noreply, socket}
  end

  defp send_issues_time_auth?(list, payload) do
    {org, repo} = Managment.init_url(payload["url"])
    if payload["token"] == "" || payload["token"] == nil  do
      Managment.send_issues_time(list, org, repo)
    else
      with {:ok, token} <- valid?(payload["token"]) do
        Managment.send_issues_time(list, org, repo, Tentacat.Client.new(%{access_token: token}))
      end
    end
  end
  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (metrics:lobby).

  # Add authorization logic here as required.
  defp authorized?(url, payload) do
    if payload["token"] == "" || payload["token"] == nil do
      Managment.api_call(url)
    else
      with {:ok, token} <- valid?(payload["token"]) do
        Managment.api_call(url, %{access_token: token})
      end
    end
  end

  defp valid?(token) do
    token
    |> Cipher.decrypt
    with {:ok, _claims} <- Guardian.decode_and_verify(token, %{"typ" => "access"}),
         {:ok, resources, _claimes} <- Guardian.resource_from_token(token) do
         {:ok, resources["github"]}
    end
  end

  defp auth?(_payload) do
    true
  end
end
