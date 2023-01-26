defmodule CryptobotWeb.Router do
  use CryptobotWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {CryptobotWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CryptobotWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", CryptobotWeb do
    pipe_through :api

    get "/messenger_webhook", MessengerController, :verify_token
    post "/messenger_webhook", MessengerController, :handle_event

  end
end
