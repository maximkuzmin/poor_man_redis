defmodule PoorManRedis.Storage do
  @moduledoc """
  Basic genserver for getting and serving data.
  Has basic interface of put/3, get/1 and delete/1 with additional delete_if_stale/2
  """

  use GenServer
  @table_name :storage_table

  if Mix.env() == :test do
    # for testing purposes, we want ETS table to be open and named,
    # to make access to it easier and more testable
    @new_table_args [:set, :public, :named_table]

    def table_name, do: @table_name
  else
    @new_table_args [:set, :protected]
  end

  @impl GenServer
  def init(_opts) do
    table_reference = :ets.new(@table_name, @new_table_args)

    {:ok, table_reference}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec put(key :: String.t(), value :: any(), timeout :: integer() | :infinity) :: :ok
  def put(key, value, timeout \\ :infinity)
      when (is_integer(timeout) and timeout > 0) or
             timeout == :infinity do
    GenServer.cast(__MODULE__, {:put, key, value, timeout})
  end

  # clause for bad type of timeout
  def put(_key, _value, timeout) do
    {:error,
     "timeout should be Integer and positive amount of seconds, got #{inspect(timeout)} instead"}
  end

  @spec get(key :: String.t()) :: %{value: any(), expires_in: integer() | :infinity} | nil
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @spec delete(key :: String.t()) :: :ok
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @spec delete_if_stale(key :: String.t()) :: :ok
  def delete_if_stale(key) do
    GenServer.cast(__MODULE__, {:delete_if_stale, key})
  end

  @impl GenServer
  def handle_cast({:put, key, value, timeout}, table_reference) do
    expires_in = get_expires_in(timeout)
    :ets.insert(table_reference, {key, value, expires_in})
    set_ttl_cleaner(key, timeout)
    {:noreply, table_reference}
  end

  def handle_cast({:delete, key}, table_reference) do
    :ets.delete(table_reference, key)
    {:noreply, table_reference}
  end

  def handle_cast({:delete_if_stale, key}, table_reference) do
    :ets.lookup(table_reference, key)
    |> case do
      [] ->
        :noop

      # somebody updated ttl with infinity while ttl_cleaner was sleeping
      [{^key, _value, :infinity}] ->
        :noop

      # check that it's really expired
      [{^key, _value, %NaiveDateTime{} = expires_in}] ->
        NaiveDateTime.utc_now()
        |> NaiveDateTime.compare(expires_in)
        |> case do
          # it is time
          result when result in [:gt, :eq] ->
            :ets.delete(table_reference, key)

          # not now, expires_in was updated, apparently
          :lt ->
            :noop
        end
    end

    {:noreply, table_reference}
  end

  @impl GenServer
  def handle_call({:get, key}, _caller_ref, table_reference) do
    val =
      :ets.lookup(table_reference, key)
      |> case do
        # key doesn't exist
        [] ->
          nil

        [{^key, value, :infinity}] ->
          %{value: value, expires_in: :infinity}

        # key exists and expires in is NaiveDateTime
        [{^key, value, %NaiveDateTime{} = expires_in}] ->
          NaiveDateTime.utc_now()
          |> NaiveDateTime.compare(expires_in)
          |> case do
            :lt ->
              time_difference = NaiveDateTime.diff(expires_in, NaiveDateTime.utc_now())
              %{value: value, expires_in: time_difference}

            # looks like ttl_cleaner is late a bit
            # but we have it's back and will never give stale info
            val when val in [:eq, :gt] ->
              nil
          end
      end

    {:reply, val, table_reference}
  end

  @spec get_expires_in(timeout_in_seconds :: Integer.t() | :infinity) ::
          NaiveDateTime.t() | :infinity
  defp get_expires_in(timeout_in_seconds) when is_integer(timeout_in_seconds) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(timeout_in_seconds)
  end

  defp get_expires_in(:infinity), do: :infinity

  defp set_ttl_cleaner(_key, :infinity), do: :noop

  defp set_ttl_cleaner(key, timeout_in_seconds) do
    Task.start(fn ->
      :timer.seconds(timeout_in_seconds)
      |> :timer.sleep()

      __MODULE__.delete_if_stale(key)
    end)
  end
end
