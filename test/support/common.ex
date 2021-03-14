defmodule PoorManRedis.Test.Common do
  @moduledoc """
  Contains logic, often used across test suite
  """

  def generate_random_string, do: Ecto.UUID.generate()
end
