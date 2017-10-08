defmodule Gitmetrics.Managment  do
    alias Gitmetrics.Cache
    alias Tentacat.Issues.Comments
    @moduledoc """
    Modulo per github api
    """

    @spec init_url(String.t) :: {String.t, String.t}
    def init_url(url) do
       url
        |> String.split("/")
        |> Enum.reverse
        |> get_names()
    end

    #restituisce nome repository e organizzazione
    defp get_names([repo | [ org | _tail ]]), do: {org, repo} #repo | organizazione

    def api_call({org, repo}) do
       with {:ok, list} <- Cache.pull(org, repo) do
          list
          |> Flow.from_enumerable()
          |> Flow.partition()
          |> Flow.reduce(fn -> [] end, fn(x, acc) -> acc ++ [get_data(x)] end)
          |> Enum.sort()
       else
         _ -> []
       end
    end

    def get_data(issue) do
      %{
        id: Map.get(issue, "id"),
        number: Map.get(issue, "number"),
        assegnati: Map.get(issue, "assignees") |> get_assegnati(),
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

    def send_close_time([]), do: %{}
    def send_close_time(list) do
      list
      |> Enum.reduce([], fn(x, acc) -> acc ++ [
        %{number: x.number,
          time: match_date(x.created_at, x.closed_at),
        }] end)
    end

    def send_info_status([]), do: %{close_no_comments: 0, no_commentate: 0, no_labele: 0}
    def send_info_status(list) do
      %{
        close_no_comments: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.state, x.comments) end),
        no_commentate: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.comments) end),
        no_labele: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.state, x.labels) end),
      }
    end

    defp count_items(nil), do: 0
    defp count_items([]), do: 0
    defp count_items(num), do: num
    defp count_items("open", []), do: 1
    defp count_items("closed", 0), do: 1
    defp count_items(_, _), do: 0


    def send_issues_time([], _, _, _), do: %{}
    def send_issues_time(list, org, repo, client) do
      list
      |> Enum.reduce([],
          fn(x, acc) -> acc ++ [%{number: x.number,
          time: match_date(x.created_at, get_comments(org, repo, x.comments, x.number, x.created_at, client))
          }] end)
    end

    defp get_comments(_, _, 0, _, _, _), do: 0
    defp get_comments(org, repo, comments, number, created_at, client) do
        Comments.filter(org, repo, number, %{since: created_at}, client)
        |> can_i_send?()
        |> get_first_commet()
        |> Map.get("created_at")
    end

    defp match_date(issue, comment) do
      with {:ok, date_issue, 0} <- DateTime.from_iso8601(issue),
           {:ok, date_comment, 0} <- DateTime.from_iso8601(comment) do
             DateTime.diff(date_comment, date_issue)
             |> (fn(x) -> round(x/60) end).()
      else
        {:error, :invalid_format} -> 0
      end
    end

    defp get_first_commet([]), do: 0
    defp get_first_commet({:ok, [ h | _t]}), do: h
    defp get_first_commet({:error, _}), do: 0
    defp get_first_commet([ h | _t]), do: h

    def send_metrics_lista([]), do: %{issues: []}
    def send_metrics_lista(list) do
      %{issues: list}
    end

    def can_i_send?({403, _}), do: {:error, :limit}
    def can_i_send?({404, _}), do: {:error, :not_found}
    def can_i_send?(list), do: {:ok, list}

    def send_metrics_stato([]), do: %{totale: 0, aperte: 0, chiuse: 0}
    def send_metrics_stato(list) do
      %{totale: length(list),
        aperte: check(list, "open"),
        chiuse: check(list, "closed"),
      }
    end

    defp check([], _), do: 0
    defp check(list, key), do: Enum.reduce(list, 0, fn(x, acc) -> acc + does_match?(x.state, key) end)
    defp does_match?(left, right) when left == right, do: 1
    defp does_match?(left, right) when left != right, do: 0
end
