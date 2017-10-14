defmodule Gitmetrics.Cache do

  alias Gitmetrics.Managment

  @moduledoc """
  The boundary for the Notification system.
  """

  #Push notification caching function
  #just get from cache if get error set inside cache otherwise just update.

  @doc """
  funzione per caricamento del ETC come cash
  """
  def push(repo, value) do
    case Cachex.get(:cache, repo) do
      {:missing, nil } -> #se non trova setta
          Cachex.set(:cache, repo, value)
          {:ok, value}
      {:ok, list} -> #altrimenti aggiorna
          Cachex.update(:cache, repo, value)
          {:ok, list}
    end
  end

  @doc """
  Funzione per aggiorna datti nella cash chiamando con la libreria Tentacat
  controllo della risposta atraverso can_i_send? e push nella cash
  """
  def update(org, repo, client) do
    with {:ok, list} <- Tentacat.Issues.filter(org, repo, %{state: "all"}, client)
                        |> IO.inspect
                        |> Managment.can_i_send? do
      push("#{org}/#{repo}", list)
    end
  end

  @doc """
  Chiamata del update del cash senza authenticatione
  """
  def update(org, repo) do
    with {:ok, list} <- Tentacat.Issues.filter(org, repo, %{state: "all"})
                        |> IO.inspect
                        |> Managment.can_i_send? do
      push("#{org}/#{repo}", list)
    end
  end

  @doc """
  prendo dati dalla cash -> return {:ok, list} | {:missing, nil}
  """
  def pull(org, repo, client) do
    with {:ok, list} <- Cachex.get(:cache, "#{org}/#{repo}") do
      {:ok, list}
    else
      _ -> update(org, repo, client)
    end
  end

  def pull(org, repo) do
    with {:ok, list} <- Cachex.get(:cache, "#{org}/#{repo}") do
      {:ok, list}
    else
      _ -> update(org, repo)
    end
  end
 @doc """
 cancello chiave dalla cash
 """
  def clean_key(org, repo) do
    with {:ok, true} <- Cachex.exists?(:cache, "#{org}/#{repo}") do
      Cachex.del(:cache, "#{org}/#{repo}")
    end
  end
end
