defmodule Gitmetrics.Cache do
  @moduledoc """
  The boundary for the Notification system.
  """

  #Push notification caching function
  #just get from cache if get error set inside cache otherwise just update.

  defp push(repo, value) do
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
    with {:ok, list} <- Tentacat.Issues.filter(org, repo, %{state: "all"}, client) |> can_i_send? do
      push("#{org}/#{repo}", list)
    end
  end

  defp can_i_send?({403, _}), do: {:error, :limit}
  defp can_i_send?(list), do: {:ok, list}
  @doc """
  Just get list from cache and return {:ok, list} | {:missing, nil}
  """
  def pull(org, repo) do
    with {:ok, list} <- Cachex.get(:cache, "#{org}/#{repo}") do
      {:ok, list}
    else
      _ ->  auth = Tentacat.Client.new(%{user: "FelisOrion", password: "salaculo21122012"})
            update(org, repo, auth)
    end
  end

  def clean_key(org, repo) do
    with {:ok, true} <- Cachex.exists?(:cache, "#{org}/#{repo}") do
      Cachex.del(:cache, "#{org}/#{repo}")
    end
  end
end
