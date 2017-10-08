defmodule Gitmetrics.Cache do

  alias Gitmetrics.Managment

  @moduledoc """
  The boundary for the Notification system.
  """

  #Push notification caching function
  #just get from cache if get error set inside cache otherwise just update.

  def push(repo, value) do
    case Cachex.get(:cache, repo) do
      {:missing, nil } ->
          Cachex.set(:cache, repo, value)
          {:ok, value}
      {:ok, list} ->
          Cachex.update(:cache, repo, value)
          {:ok, list}
    end
  end

  def update(org, repo, client) do
    with {:ok, list} <- Tentacat.Issues.filter(org, repo, %{state: "all"}, client)
                        |> Managment.can_i_send? do
      push("#{org}/#{repo}", list)
    end
  end

  def update(org, repo) do
    with {:ok, list} <- Tentacat.Issues.filter(org, repo, %{state: "all"})
                        |> Managment.can_i_send? do
      push("#{org}/#{repo}", list)
    end
  end

  @doc """
  Just get list from cache and return {:ok, list} | {:missing, nil}
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

  def clean_key(org, repo) do
    with {:ok, true} <- Cachex.exists?(:cache, "#{org}/#{repo}") do
      Cachex.del(:cache, "#{org}/#{repo}")
    end
  end
end
