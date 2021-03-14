defmodule PoorManRedis.Storage.Put do
  @moduledoc """
  Describes pipeline of storing some data inside storage.
  Handles put operation and if successful, informs websockets about it
  """
  alias PoorManRedis.Storage

  @spec call(key :: String.t(), value :: any(), timeout :: integer() | :infinity) :: :ok
  def call(key, value, ttl \\ :infinity) do
    with :ok <- Storage.put(key, value, ttl) do
      inform_websocket(key, value)
      :ok
    else
      {:error, _} = error_tuple -> error_tuple
    end
  end

  defp inform_websocket(_, _), do: :noop
end
