defmodule PoorManRedis.Storage.DeleteIfStale do
  @moduledoc """
  Handles logic of delete if stale Storage action. Informs websocket about key state if it was deleted
  """
  alias PoorManRedis.Storage
  alias PoorManRedisWeb.Endpoint

  @spec call(String.t()) :: :ok
  def call(key) do
    # it's always ok because of ETS delete logic
    :ok = Storage.delete_if_stale(key)

    receive do
      :deleted ->
        inform_websocket(key)

      _ ->
        :noop
    end

    :ok
  end

  defp inform_websocket(key) do
    Endpoint.broadcast("key:#{key}", "Was deleted after expiration", %{})
  end
end
