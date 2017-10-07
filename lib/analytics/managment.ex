defmodule Gitmetrics.Managment  do
    @moduledoc """
    Modulo per github api
    """

    @spec init_url(String.t) :: {String.t, String.t}
    def init_url(url) do
       url
        |> String.split("/")
        |> Enum.reverse
        |> get_names
    end

    #restituisce nome repository e organizzazione
    defp get_names([repo | [ org | _tail ]]), do: {org, repo} #repo | organizazione

    def api_call({org, repo}) do
       Tentacat.Issues.list(org, repo)
       |> Enum.reduce([], fn(x, acc) -> acc ++ [get_data(x)] end)
       |> send_metrics()
    end

    defp get_data(issue) do
      %{ assegnati: Map.get(issue, "assignees") |> get_assegnati(),
        body: Map.get(issue, "body"),
        created_at: Map.get(issue, "created_at"),
        closed_at: Map.get(issue, "closed_at"),
        comments: Map.get(issue, "comments"),
        title: Map.get(issue, "title"),
        updated_at: Map.get(issue, "updated_at"),
        url: Map.get(issue, "html_url"),
        labels: Map.get(issue, "labels") |> get_labels(),
        state:  Map.get(issue, "state"),
      }
    end

    defp get_assegnati([]), do: []
    defp get_assegnati(lista) do
      lista
      |> Enum.reduce([], fn(x, acc) -> acc ++ [
        %{
          avatar: Map.get(x, "avatar_url"),
          name: Map.get(x, "login"),
         }] end)
    end

    defp get_labels([]), do: []
    defp get_labels(list) do
      list
      |> Enum.reduce([], fn(x, acc) -> acc ++ [
        %{
          name: Map.get(x, "name"),
          color: Map.get(x, "color"),
          }] end)
    end

    def send_metrics(list) do
      %{totale: length(list),
        aperte: Enum.reduce(list, 0, fn(x, acc) -> if x.state == "open", do: acc+1 end),
        chiuse: Enum.reduce(list, 0, fn(x, acc) -> if x.state == "closed", do: acc+1 end),
      }
    end
end
