defmodule PoorManRedisWeb.KeyChannelTest do
  use PoorManRedisWeb.ChannelCase

  alias PoorManRedis.Storage
  alias PoorManRedisWeb.StorageSocket
  alias PoorManRedisWeb.KeyChannel, as: Described
  alias PoorManRedis.Storage.{Delete, Put}

  setup do
    key = generate_random_string()
    value = generate_random_string()

    {:ok, _, _socket} =
      StorageSocket
      |> socket()
      |> subscribe_and_join(Described, "key:#{key}")

    %{key: key, value: value}
  end

  test "it pushes down to socket information about it's update", %{
    key: key,
    value: value
  } do
    Put.call(key, value)
    assert_broadcast "Was updated", %{value: ^value, expires_in: :infinity}
  end

  test "it pushes down to socket information about it's delete", %{
    key: key
  } do
    Delete.call(key)
    assert_broadcast "Was deleted", %{}
  end

  test "it pushes down to socket information about it's delete after expiration", %{
    key: key,
    value: value
  } do
    Storage.put(key, value, 1)
    :timer.sleep(1_000)
    assert_broadcast "Was deleted after expiration", %{}
  end
end
