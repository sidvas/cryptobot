defmodule Cryptobot.ChatBot do
  alias Cryptobot.MessageHandler
  alias Cryptobot.MessageHelper

  def verify(params) do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    params["hub.mode"] == "subscribe" && params["hub.verify_token"] == facebook_config.webhook_verify_token
  end

  def send_message(msg) do
    url = messages_endpoint()
    HTTPoison.post!(url, Jason.encode!(msg), [{"Content-type", "application/json"}])
  end

  def handle_webhook(event) do
    case MessageHelper.get_messaging(event) do
      %{"message" => msg} -> MessageHandler.reply(msg, event)
      %{"postback" => postback} -> MessageHandler.reply_to_selection(postback, event)
      _ ->
        err_msg = MessageHelper.text_reply(event, "GG you messsed something up bad")
        send_message(err_msg)
    end
  end

  defp messages_endpoint() do
    facebook_config = Application.get_env(:cryptobot, :facebook_config)
    token_path = "?access_token=#{facebook_config.webhook_verify_token}"
    Path.join([facebook_config.base_url, facebook_config.api_version, facebook_config.message_url, token_path])
  end
end
