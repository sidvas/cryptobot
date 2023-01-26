defmodule Cryptobot.ChatBot do

  def verify(params) do
    chatbot_config = Application.get_env(:cryptobot, :facebook_chat_bot)
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == chatbot_config.webhook_verify_token
  end
end
