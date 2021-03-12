defmodule PoorManRedisWeb.StorageController do
  use PoorManRedisWeb, :controller

  alias PoorManRedis.Storage

  def get(conn, %{"key" => key}) do
    result = Storage.get(key)
    render(conn, "result.json", result: result)
  end

  def put(conn, %{"key" => key, "value" => value, "ttl" => ttl}) do
    Storage.put(key, value, ttl)
    |> render_ok_or_error(conn)
  end

  def put(conn, %{"key" => key, "value" => value}) do
    Storage.put(key, value)
    |> render_ok_or_error(conn)
  end

  def delete(conn, %{"key" => key}) do
    key
    |> Storage.delete()
    |> render_ok_or_error(conn)
  end

  defp render_ok_or_error(action_result, conn) do
    action_result
    |> case do
      :ok ->
        render(conn, "ok.json")

      {:error, reason} ->
        render(conn, "error.json", error: reason)
    end
  end
end
