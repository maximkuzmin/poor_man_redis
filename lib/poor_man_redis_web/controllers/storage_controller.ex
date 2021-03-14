defmodule PoorManRedisWeb.StorageController do
  @moduledoc """
  Serves and stores values from storage
  """
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

  # clause for invalid params
  def put(conn, params) do
    error_message = ~s|
      Endpoint expects "value" parameter (required)
      and optional "ttl" parameter, that should be a positive number.
      Got "#{inspect(params)}" instead
      |

    render_ok_or_error({:error, error_message}, conn)
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
        conn
        |> put_status(400)
        |> render("error.json", error_message: reason)
    end
  end
end
