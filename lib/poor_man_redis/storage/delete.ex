defmodule PoorManRedis.Storage.Delete do
  @moduledoc """
  Handles deletion from Storage in the application
  """
  alias PoorManRedis.Storage
  alias PoorManRedisWeb.Endpoint

  @spec call(String.t()) :: :ok
  def call(key) do
    # it's always ok because of ETS delete logic
    :ok = Storage.delete(key)
    inform_websocket(key)
    :ok
  end

  defp inform_websocket(key) do
    Endpoint.broadcast("key:#{key}", "Was deleted", %{})
  end
end
