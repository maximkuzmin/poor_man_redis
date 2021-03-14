defmodule PoorManRedis.StorageTest do
  use PoorManRedis.DataCase

  alias PoorManRedis.Storage, as: Described

  @timeout 1

  setup do
    {:ok, key: generate_random_string(), value: generate_random_string()}
  end

  describe "put/3 and get" do
    test ~S| put(key, data) replies with :ok
             and puts data into ETS table under provided key
             with infinite TTL|,
         %{key: key, value: value} do
      assert(:ok = Described.put(key, value))
      :timer.sleep(10)
      assert(:ets.lookup(Described.table_name(), key) == [{key, value, :infinity}])
    end

    test ~S| put(key, data, timeout) replies with :ok
             and puts data into ETS table under provided key
             with NaiveDateTime expires_in val and after TLL finished, deletes it|,
         %{key: key, value: value} do
      assert(:ok = Described.put(key, value, @timeout))
      :timer.sleep(10)
      assert([{key, ^value, %NaiveDateTime{}}] = :ets.lookup(Described.table_name(), key))
      assert(%{value: ^value, expires_in: expires_in} = Described.get(key))
      assert(is_integer(expires_in))

      :timer.seconds(@timeout)
      |> :timer.sleep()

      assert(is_nil(Described.get(key)))
    end

    test "put(key, list()) works too", %{key: key, value: value} do
      value_list = String.split(value, "")
      assert(:ok = Described.put(key, value_list))
      assert(%{value: ^value_list} = Described.get(key))
    end

    test "put(key, map) works too", %{key: key, value: value} do
      value_map = %{value => value}
      assert(:ok = Described.put(key, value_map))
      assert(%{value: ^value_map} = Described.get(key))
    end
  end

  describe "delete" do
    setup %{key: key, value: value} do
      Described.put(key, value)
      {:ok, []}
    end

    test "delete(key) deletes record", %{key: key, value: value} do
      # check if it's in place
      assert(%{value: ^value} = Described.get(key))
      # Delete it
      assert(:ok = Described.delete(key))
      # Check that it's deleted
      assert(is_nil(Described.get(key)))
    end

    test "delete(key) replies :ok even if there is no such key", %{key: key} do
      weird_key = String.reverse(key)
      assert(is_nil(Described.get(weird_key)))

      assert(:ok = Described.delete(weird_key))
    end
  end
end
