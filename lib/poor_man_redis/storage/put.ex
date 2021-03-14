defmodule PoorManRedis.Storage.Put do
  @moduledoc """
  Describes pipeline of storing some data inside storage.
  Handles put operation and if successful, informs websockets about it
  """
  alias PoorManRedis.Storage
  alias PoorManRedisWeb.Endpoint

  @spec call(key :: String.t(), value :: any(), timeout :: integer() | :infinity) :: :ok
  def call(key, value, ttl \\ :infinity) do
    Storage.put(key, value, ttl)
    |> case do
      :ok ->
        inform_websocket(key, value, ttl)
        :ok

      {:error, _} = error_tuple ->
        error_tuple
    end
  end

  defp inform_websocket(key, val, ttl) do
    Endpoint.broadcast("key:#{key}", "Was updated", %{value: val, expires_in: ttl})
  end
end
