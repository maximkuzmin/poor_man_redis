defmodule PoorManRedisWeb.KeyChannel do
  @moduledoc """
  Phoenix channel that handles key status updates in the Storage.
  """
  use PoorManRedisWeb, :channel

  alias PoorManRedis.Storage

  def join("key:" <> storage_key, _params, socket) do
    value = Storage.get(storage_key)
    response = %{key: value}
    {:ok, response, socket}
  end
end
