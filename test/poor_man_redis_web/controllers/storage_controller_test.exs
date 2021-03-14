defmodule PoorManRedisWeb.StorageControllerTest do
  use PoorManRedisWeb.ConnCase

  alias PoorManRedis.Storage

  @valid_ttl 1

  describe "put String" do
    setup do
      key = generate_random_string()
      value = generate_random_string()

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is string", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end

    test "responds with 200 and stores string value for infinite ttl if key is absurdly long string",
         %{
           conn: conn,
           key: key,
           value: value
         } do
      key = Enum.reduce(1..1000, "", fn _, acc -> acc <> key end)

      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end

    test "responds with 400 and stores nothing if params are invalid", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{weird_value: value}))

      assert(%{"error" => _} = json_response(resp_conn, 400))
      assert(nil == Storage.get(key))
    end

    test "responds with 200 and stores value with ttl when ttl parameter is provided", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(
          Routes.storage_path(conn, :put, key),
          Jason.encode!(%{value: value, ttl: @valid_ttl})
        )

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: expires_in} = Storage.get(key))
      assert(is_integer(expires_in))
    end

    test "responds with 400 and stores nothing when ttl parameter is invalid(string)", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(
          Routes.storage_path(conn, :put, key),
          Jason.encode!(%{value: value, ttl: "invalid_ttl"})
        )

      assert(%{"error" => _} = json_response(resp_conn, 400))
      assert(nil == Storage.get(key))
    end
  end

  describe "put List of strings" do
    setup do
      key = generate_random_string()
      value = 1..1000 |> Enum.map(fn _ -> generate_random_string() end)

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is List", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end
  end

  describe "put Map" do
    setup do
      key = generate_random_string()

      value = %{
        "map_key" => generate_random_string(),
        "another_map_key" => generate_random_string()
      }

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is Map", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end
  end

  describe "put Nil" do
    setup do
      key = generate_random_string()

      value = nil

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is Map", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end
  end

  describe "put Integer" do
    setup do
      key = generate_random_string()

      value = :rand.uniform(1_000_000)

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is Map", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end
  end

  describe "put Float" do
    setup do
      key = generate_random_string()

      value = 36.6

      {:ok, key: key, value: value}
    end

    test "responds with 200 and stores value for infinite ttl if stored value is Map", %{
      conn: conn,
      key: key,
      value: value
    } do
      resp_conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(Routes.storage_path(conn, :put, key), Jason.encode!(%{value: value}))

      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(%{value: ^value, expires_in: :infinity} = Storage.get(key))
    end
  end

  describe "get String" do
    setup do
      key = generate_random_string()
      value = generate_random_string()
      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "get List" do
    setup do
      key = generate_random_string()
      value = 1..1000 |> Enum.map(fn _ -> generate_random_string() end)
      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "get Map" do
    setup do
      key = generate_random_string()

      value = %{
        "map_key" => generate_random_string(),
        "another_map_key" => generate_random_string()
      }

      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "get Integer" do
    setup do
      key = generate_random_string()

      value = :rand.uniform(1_000_000)

      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "get Float" do
    setup do
      key = generate_random_string()

      value = 36.123456789

      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "get Nil" do
    setup do
      key = generate_random_string()

      value = nil

      :ok = Storage.put(key, value)
      {:ok, key: key, value: value}
    end

    test "get returns value from storage", %{conn: conn, key: key, value: value} do
      resp_conn = get(conn, Routes.storage_path(conn, :get, key))
      assert(%{"value" => ^value, "expires_in" => _} = json_response(resp_conn, 200))
    end
  end

  describe "delete" do
    setup do
      key = generate_random_string()

      value = generate_random_string()

      :ok = Storage.put(key, value)
      {:ok, key: key}
    end

    test "delete responds with 200 and deletes record from storage", %{conn: conn, key: key} do
      resp_conn = delete(conn, Routes.storage_path(conn, :delete, key))
      assert(%{"ok" => true} = json_response(resp_conn, 200))
      assert(nil == Storage.get(key))
    end
  end
end
