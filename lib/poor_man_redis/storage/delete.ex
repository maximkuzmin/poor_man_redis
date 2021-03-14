defmodule PoorManRedis.Storage.Delete do
  @moduledoc """
  Handles deletion from Storage in the application
  """
  alias PoorManRedis.Storage

  @spec call(String.t()) :: :ok
  def call(key) do
    # it's always ok because of ETS delete logic
    :ok = Storage.delete(key)
    inform_websocket(key)
    :ok
  end

  defp inform_websocket(_key), do: :noop
end
