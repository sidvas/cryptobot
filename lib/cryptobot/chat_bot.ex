defmodule Cryptobot.ChatBot do

  def verify(params) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == facebook_config.webhook_verify_token
  end
end
