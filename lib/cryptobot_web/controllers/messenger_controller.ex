defmodule CryptobotWeb.MessengerController do
  use CryptobotWeb, :controller

  def verify_token(conn, params) do
    verified? = Cryptobot.ChatBot.verify(params)
    if verified? do
      conn
      |> put_resp_content_type("application/json")
      |> resp(200, params["hub.challenge"])
      |> send_resp()
    else
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, "")
    end
  end

  def handle_event(conn, event) do
    Cryptobot.ChatBot.handle_event(event)

    conn
    |> put_resp_content_type("application/json")
    |> resp(200, Jason.encode!(%{status: "ok"}))
  end
end
