defmodule PoorManRedisWeb.Router do
  use PoorManRedisWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PoorManRedisWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/storage/:key", StorageController, :get
    post "/storage/:key", StorageController, :put
    delete "/storage/:key", StorageController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", PoorManRedisWeb do
  #   pipe_through :api
  # end
end
