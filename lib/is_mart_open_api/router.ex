defmodule IsMartOpenApi.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/search/:mart" do
    result = IsMartOpenApi.Search.search!(mart, "")

    body =
      if length(result) == 0 do
        %{:error => "검색 결과가 없습니다."}
        |> Jason.encode!()
      else
        %{:result => result}
        |> Jason.encode!()
      end

    conn
    |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=utf8")
    |> send_resp(200, body)
  end

  get "/search/:mart/:keyword" do
    result = IsMartOpenApi.Search.search!(mart, keyword)

    body =
      if length(result) == 0 do
        %{:error => "검색 결과가 없습니다."}
        |> Jason.encode!()
      else
        %{:result => result}
        |> Jason.encode!()
      end

    conn
    |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=utf8")
    |> send_resp(200, body)
  end

  get "/info/:mart/:name" do
    result = IsMartOpenApi.Info.info!(mart, name)

    body =
      if result != nil do
        result
        |> Jason.encode!()
      else
        %{:error => "검색 결과가 없습니다."}
        |> Jason.encode!()
      end

    conn
    |> Plug.Conn.put_resp_header("Content-Type", "application/json; charset=utf8")
    |> send_resp(200, body)
  end

  match _ do
    send_resp(conn, 404, "Bad Request")
  end

  defp handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}) do
    send_resp(conn, conn.status, "Something went wrong")
  end
end
