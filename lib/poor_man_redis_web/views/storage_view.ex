defmodule PoorManRedisWeb.StorageView do
  use PoorManRedisWeb, :view

  def render("ok.json", _), do: %{ok: true}

  def render("error.json", %{error_message: error_message}), do: %{error: error_message}

  def render("result.json", %{result: result}) when is_map(result), do: result
end
