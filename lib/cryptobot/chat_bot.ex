defmodule Cryptobot.ChatBot do

  def verify(params) do
    webhook_verify_token = Application.get_env(:cryptobot, :fb_webhook_verify_token)
    IO.inspect(webhook_verify_token)
    IO.inspect(params["hub.verify_token"])
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == webhook_verify_token
  end
end
