defmodule Gitmetrics.Managment  do
    alias Gitmetrics.Cache
    alias Tentacat.Issues.Comments
    @moduledoc """
    Modulo per github api
    """


    @doc """
    Prendo dal url solo ultime due parti -> organizzazione e ripo
    """
    @spec init_url(String.t) :: {String.t, String.t}
    def init_url(url) do
       url
        |> String.split("/")
        |> Enum.reverse
        |> get_names()
    end

    #restituisce nome repository e organizzazione
    defp get_names([""]), do: []
    defp get_names(["" | [repo | [ org | tail]]]), do: {org, repo}
    defp get_names([repo | [ org | _tail ]]), do: {org, repo} #repo | organizazione


    @doc """
    Chiamata principale della lista di tutti issue presenti da qualle poi verano costruite grafici
    nel caso la trova gia nella cash la carica semplicemente.
    due Implementazione sia per autorizzati che non.
    """
    def api_call({org, repo}, client) do
       with {:ok, list} <- Cache.pull(org, repo, Tentacat.Client.new(client)) do
          list
          |> Flow.from_enumerable()
          |> Flow.partition()
          |> Flow.reduce(fn -> [] end, fn(x, acc) -> acc ++ [get_data(x)] end)
          |> Enum.sort()
       else
         _ -> []
       end
    end

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


    @doc """
    inserisci dati delle issue in una mappa dalla chiamata api_call
    """
    def get_data(issue) do
      %{
        id: Map.get(issue, "id"),
        number: Map.get(issue, "number"),
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

    #ritorna labels del issue
    defp get_labels([]), do: []
    defp get_labels(list) do
      list
      |> Enum.reduce([], fn(x, acc) -> acc ++ [
        %{
          name: Map.get(x, "name"),
          color: Map.get(x, "color"),
          }] end)
    end

    @doc """
    Restituisce lista con dentro mappate il numero del issue e suo diff del tempo di chiusura
    Tempo.creazione - Tempo.chiusura
    """
    def send_close_time([]), do: %{}
    def send_close_time(list) do
      list
      |> Enum.reduce([], fn(x, acc) -> acc ++ [
        %{number: x.number,
          time: match_date(x.created_at, x.closed_at),
        }] end)
    end

    @doc """
    Restituisce lista di stato con tutte issue (chiuse senza commento,
    non commentate e senza un label)
    """
    def send_info_status([]), do: %{close_no_comments: 0, no_commentate: 0, no_labele: 0}
    def send_info_status(list) do
      %{
        close_no_comments: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.state, x.comments) end),
        no_commentate: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.comments) end),
        no_labele: Enum.reduce(list, 0, fn(x, acc) -> acc + count_items(x.state, x.labels) end),
      }
    end

    #funzione per restituire se 1 / 0 nella condizione del pattern mattching
    defp count_items(nil), do: 0
    defp count_items([]), do: 0
    defp count_items(num), do: num
    defp count_items("open", []), do: 1
    defp count_items("closed", 0), do: 1
    defp count_items(_, _), do: 0

    @doc """
    Ritorna lista del tempo dalla creazione alla prima risposta
    """
    def send_issues_time([], _, _), do: %{}
    def send_issues_time([], _, _, _), do: %{}
    def send_issues_time(list, org, repo) do
      list
      |> Enum.reduce([],
          fn(x, acc) -> acc ++ [%{number: x.number,
          time: match_date(x.created_at, get_comments(org, repo, x.comments, x.number, x.created_at))
          }] end)
      |> save_in_cache(org, repo)
    end

    def send_issues_time(list, org, repo, client) do
      list
      |> Enum.reduce([],
          fn(x, acc) -> acc ++ [%{number: x.number,
          time: match_date(x.created_at, get_comments(org, repo, x.comments, x.number, x.created_at, client))
          }] end)
      |> save_in_cache(org, repo)
    end

    #chiama api per caricare commenti ad ogni issue e prendere solo primo rispetto un tempo
    defp get_comments(_, _, 0, _, _, _), do: 0
    defp get_comments(org, repo, comments, number, created_at, client) do
        Comments.filter(org, repo, number, %{since: created_at}, client)
        |> can_i_send?()
        |> get_first_commet()
        |> Map.get("created_at")
    end

    #per chiammata non authenticata cambia solo numero di rate limit
    defp get_comments(_, _, 0, _, _), do: 0
    defp get_comments(org, repo, comments, number, created_at) do
        Comments.filter(org, repo, number, since: created_at)
        |> can_i_send?()
        |> get_first_commet()
        |> Map.get("created_at")
    end

    defp save_in_cache(list, org, repo) do
      Cache.push("#{org}/#{repo}/resptime", list)
      list #ritorno lista
    end

    #fa la diffrenza tra que date
    #prima la trasforma da string e poi con funzione diff restituisce secondi in differenza
    defp match_date(issue, comment) do
      with {:ok, date_issue, 0} <- DateTime.from_iso8601(issue),
           {:ok, date_comment, 0} <- DateTime.from_iso8601(comment) do
             DateTime.diff(date_comment, date_issue)
             |> (fn(x) -> round(x/60) end).() #per trasformare in minuti
      else
        {:error, :invalid_format} -> 0
      end
    end


    #pattern match per restituire prima commento se lo trova
    defp get_first_commet([]), do: 0
    defp get_first_commet({:ok, [ h | _t]}), do: h
    defp get_first_commet({:error, _}), do: 0
    defp get_first_commet([ h | _t]), do: h

    @doc """
    restituisce la lista con descrizioni titolo e body delle issue
    """
    def send_metrics_lista([]), do: %{issues: []}
    def send_metrics_lista(list) do
      %{issues: list}
    end

    #controlla se la risposta non sia un errore
    def can_i_send?({401, _}), do: {:error, :bad_credintial}
    def can_i_send?({403, _}), do: {:error, :limit} #now panic
    def can_i_send?({404, _}), do: {:error, :not_found}
    def can_i_send?(list), do: {:ok, list}

    @doc """
    Restituisce totale di issue e aperte, chiuse e in generale
    """
    def send_metrics_stato([]), do: %{totale: 0, aperte: 0, chiuse: 0}
    def send_metrics_stato(list) do
      %{totale: length(list),
        aperte: check(list, "open"),
        chiuse: check(list, "closed"),
      }
    end

    #conta quante sono le issue con un certo mark open / closed
    defp check([], _), do: 0
    defp check(list, key), do: Enum.reduce(list, 0, fn(x, acc) -> acc + does_match?(x.state, key) end)
    defp does_match?(left, right) when left == right, do: 1
    defp does_match?(left, right) when left != right, do: 0
end
